import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import 'package:pawpal/screens/onboarding/splash_screen.dart';
import 'package:pawpal/screens/onboarding/walkthrough_screen.dart';
import 'package:pawpal/screens/auth/login_screen.dart';
import 'package:pawpal/screens/auth/register_screen.dart';
import 'package:pawpal/screens/auth/forgot_password_screen.dart';
import 'package:pawpal/screens/auth/verification_screen.dart';

import 'package:pawpal/screens/home/homepage.dart';
import 'package:pawpal/screens/profile/profile_screen.dart';
import 'package:pawpal/screens/profile/edit_profile_screen.dart';
import 'package:pawpal/screens/profile/profile_faq_screen.dart';
import 'package:pawpal/screens/shop/shop.dart';
import 'package:pawpal/screens/shop/cart_screen.dart';
import 'package:pawpal/screens/adoption/adoption_list.dart';
import 'package:pawpal/screens/vet/vet_list_screen.dart';
import 'package:pawpal/screens/vet/vet_appointment_screen.dart';
import 'package:pawpal/screens/vet/vet_appointment_summary_screen.dart';

/// Strongly-typed args for the summary screen
class VetSummaryArgs {
  final String? serviceTitle;
  final double? servicePrice;
  final String? dateLabel;
  final String? timeSlot;
  const VetSummaryArgs({
    this.serviceTitle,
    this.servicePrice,
    this.dateLabel,
    this.timeSlot,
  });
}

/// Simple refresh listenable so auth changes trigger go_router redirects
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _auth = FirebaseAuth.instance;

  /// Global navigator key so we can route from outside BuildContext (e.g., FCM)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(_auth.authStateChanges()),

    /// Auth guard:
    /// - Always allow '/splash' to render (so you actually see it on web)
    /// - If not logged in: allow onboarding/auth routes; redirect others -> /login
    /// - If logged in and on /login or /register or /walkthrough -> /home
    redirect: (context, state) {
      final isLoggedIn = _auth.currentUser != null;
      final loc = state.matchedLocation;

      // 1) Always allow splash to show
      if (loc == '/splash') return null;

      // 2) Onboarding/auth route checks
      final isOnboarding = loc == '/walkthrough';
      final isAuthRoute = loc == '/login' || loc == '/register' || loc == '/forgot' || loc == '/verify';

      if (!isLoggedIn) {
        // Unauthed can access onboarding & auth; everything else goes to /login
        if (isOnboarding || isAuthRoute) return null;
        return '/login';
      }

      // Logged in: keep them off the auth/onboarding routes
      if (isLoggedIn && (isOnboarding || loc == '/login' || loc == '/register')) {
        return '/home';
      }

      return null;
    },

    routes: [
      // Onboarding & Auth
      GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
      GoRoute(path: '/walkthrough', builder: (_, __) => WalkthroughScreen()),
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => ForgotPasswordScreen()),
      GoRoute(path: '/verify', builder: (_, __) => VerificationScreen()),

      // App core
      GoRoute(path: '/home', builder: (_, __) => HomePage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/profile/faq', builder: (_, __) => ProfileFaqScreen()),

      GoRoute(path: '/shop', builder: (_, __) => ShopScreen()),
      GoRoute(path: '/cart', builder: (_, __) => CartScreen()),
      GoRoute(path: '/adoption', builder: (_, __) => AdoptionListScreen()),
      GoRoute(path: '/veterinarian', builder: (_, __) => VetListScreen()),

      // Vets with path params + typed extras
      GoRoute(
        path: '/vet/:vetId/appointment',
        builder: (_, state) => VetAppointmentScreen(
          vetId: state.pathParameters['vetId']!,
        ),
      ),
      GoRoute(
        path: '/vet/:vetId/summary',
        builder: (_, state) {
          final args = state.extra as VetSummaryArgs?;
          return VetAppointmentSummaryScreen(
            vetId: state.pathParameters['vetId']!,
            serviceTitle: args?.serviceTitle,
            servicePrice: args?.servicePrice,
            dateLabel: args?.dateLabel,
            timeSlot: args?.timeSlot,
          );
        },
      ),
    ],

    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found\n${state.error}', textAlign: TextAlign.center),
      ),
    ),
  );

  /// Optional: FCM deep-link entrypoint
  static void handleNotificationTap(Map<String, dynamic> data) {
    final action = (data['action'] ?? data['type'] ?? '').toString();
    switch (action) {
      case 'open_vet_list':
        router.push('/veterinarian');
        return;
      case 'open_vet_appointment':
        final vetId = data['vetId']?.toString();
        if (vetId == null || vetId.isEmpty) {
          router.push('/veterinarian');
          return;
        }
        router.push('/vet/$vetId/appointment');
        return;
      case 'open_vet_summary':
        final vetId = data['vetId']?.toString();
        if (vetId == null || vetId.isEmpty) {
          router.push('/veterinarian');
          return;
        }
        final args = VetSummaryArgs(
          serviceTitle: _asStringOrNull(data['serviceTitle']),
          servicePrice: _asDoubleOrNull(data['servicePrice']),
          dateLabel: _asStringOrNull(data['dateLabel']),
          timeSlot: _asStringOrNull(data['timeSlot']),
        );
        router.push('/vet/$vetId/summary', extra: args);
        return;
      case 'open_home':
      default:
        router.push('/home');
        return;
    }
  }

  static String? _asStringOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _asDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
}
