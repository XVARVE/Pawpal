import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/// Centralized runtime permission helpers for Android (and iOS if needed).
/// Returns true if permission is granted (or not required).
class PermissionService {
  /// Android 13+ (Tiramisu) needs POST_NOTIFICATIONS at runtime.
  static Future<bool> ensureNotificationPermission() async {
    if (kIsWeb) return true; // not applicable
    // iOS handled by FirebaseMessaging.requestPermission() typically; skip here
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final res = await Permission.notification.request();
    if (res.isGranted) return true;

    if (res.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  /// For choosing from gallery / photo picker.
  /// On Android 13+: READ_MEDIA_IMAGES
  /// On Android <=12: READ_EXTERNAL_STORAGE (if your flow needs direct file access)
  /// Note: If you exclusively use the Android Photo Picker (image_picker supports it),
  /// you may not need storage permissions on Android 13+. This keeps a safe check anyway.
  static Future<bool> ensurePhotoPermission() async {
    if (kIsWeb) return true;
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      if (status.isGranted) return true;
      final res = await Permission.photos.request();
      if (res.isGranted) return true;
      if (res.isPermanentlyDenied) await openAppSettings();
      return false;
    }
    if (Platform.isAndroid) {
      // Try modern images permission first (SDK 33+). If unknown on older devices, fall back.
      final images = await Permission.photos.status; // maps to READ_MEDIA_IMAGES on Android
      if (images.isGranted) return true;

      final res = await Permission.photos.request();
      if (res.isGranted) return true;

      // Fallback for older devices if your picker needs it:
      final legacy = await Permission.storage.status;
      if (legacy.isGranted) return true;
      final legacyRes = await Permission.storage.request();
      if (legacyRes.isGranted) return true;

      if (res.isPermanentlyDenied || legacyRes.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  /// For taking a photo with the camera.
  static Future<bool> ensureCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final res = await Permission.camera.request();
    if (res.isGranted) return true;
    if (res.isPermanentlyDenied) await openAppSettings();
    return false;
  }
}
