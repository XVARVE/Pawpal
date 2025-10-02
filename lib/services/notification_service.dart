import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:pawpal/router/app_router.dart'; // if you want tap-deeplinks
import 'package:pawpal/services/permission_service.dart'; // ✅ ask runtime notif permission on Android 13+

/// Android/iOS background handler (Android will use this)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Guard against duplicate Firebase init in the background isolate
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    } else {
      Firebase.app();
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // Keep light; avoid heavy work. No navigation here.
  debugPrint('[FCM][BG] title=${message.notification?.title} data=${message.data}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService I = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const String _defaultChannelId   = 'pawpal_default_channel';
  static const String _defaultChannelName = 'General Notifications';
  static const String _defaultChannelDesc = 'PawPal alerts and updates';

  /// 👉 For WEB: put your **public** VAPID key from Firebase Console here.
  static const String _webVapidKey = 'REPLACE_WITH_YOUR_PUBLIC_VAPID_KEY';

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;

    // 1) Background handler (ignored on web; SW handles background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2) Ask runtime permission
    //    - Android 13+: POST_NOTIFICATIONS via permission_handler (clean system dialog)
    //    - iOS/Web: FirebaseMessaging.requestPermission()
    await _requestPermissions();

    // 3) Local notifications for foreground banners (Android only)
    if (!kIsWeb) {
      await _initLocalNotifications();
    }

    // 4) Token (Android/web)
    await _syncFcmToken();

    // 5) Foreground messages → show local notif on Android (web: just log / optional UI)
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 6) Taps when app was terminated
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);

    // 7) Taps when app in background (resumed)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 8) Token refresh
    _messaging.onTokenRefresh.listen((t) => _saveToken(t));

    _inited = true;
  }

  Future<void> _requestPermissions() async {
    // Android: request POST_NOTIFICATIONS using permission_handler (nice UX),
    // then also call FCM's API for iOS/Web foreground presentation behavior.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await PermissionService.ensureNotificationPermission();
    }

    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
      announcement: false, carPlay: false,
      criticalAlert: false, provisional: false,
    );

    // On iOS/Web this controls whether to show alerts/badges/sounds in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (resp) {
        // If you attach payloads, parse & route here
        debugPrint('[LocalNotif] tapped: ${resp.payload}');
      },
    );

    const androidChannel = AndroidNotificationChannel(
      _defaultChannelId,
      _defaultChannelName,
      description: _defaultChannelDesc,
      importance: Importance.high,
    );

    final androidPlugin =
    _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> _syncFcmToken() async {
    String? token;
    if (kIsWeb) {
      // Web requires a VAPID key and a valid service worker at /firebase-messaging-sw.js
      token = await _messaging.getToken(vapidKey: _webVapidKey);
    } else {
      token = await _messaging.getToken();
    }

    if (token != null) {
      debugPrint('[FCM] token: $token');
      await _saveToken(token);
    } else {
      debugPrint('[FCM] getToken() returned null.');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[FCM] No signed-in user; skip token save.');
      return;
    }

    final platform = kIsWeb
        ? 'web'
        : switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      _ => 'other',
    };

    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.child('users/${user.uid}/fcmTokens/$token').set({
      'createdAt': now,
      'platform': platform,
    });

    debugPrint('[FCM] Token saved for ${user.uid} ($platform): $token');
  }

  void _onForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM][FG] title=${message.notification?.title} data=${message.data}');
    final notif = message.notification;
    if (notif == null) return;

    if (!kIsWeb) {
      // Android: show a local notification banner
      await _local.show(
        notif.hashCode,
        notif.title ?? 'PawPal',
        notif.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultChannelId,
            _defaultChannelName,
            channelDescription: _defaultChannelDesc,
            priority: Priority.high,
            importance: Importance.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    } else {
      // Web: browser handles notification display via the service worker.
      // Optionally show an in-app banner/snackbar here.
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Tap -> ${message.data}');
    // Optional: deep link through your router
    AppRouter.handleNotificationTap(message.data);
  }

  // Topic helpers (optional)
  Future<void> subscribe(String topic) => _messaging.subscribeToTopic(topic);
  Future<void> unsubscribe(String topic) => _messaging.unsubscribeFromTopic(topic);
}
