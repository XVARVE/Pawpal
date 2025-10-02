import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:provider/provider.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:pawpal/firebase_options.dart';
import 'package:pawpal/services/notification_service.dart';
import 'package:pawpal/services/crashlytics_observer.dart';

import 'package:pawpal/providers/cart_provider.dart';
import 'package:pawpal/providers/favourite_provider.dart';

// Home & core screens
import 'package:pawpal/screens/home/homepage.dart';
import 'package:pawpal/screens/profile/profile_screen.dart';
import 'package:pawpal/screens/shop/cart_screen.dart';
import 'package:pawpal/screens/shop/shop.dart';
import 'package:pawpal/screens/adoption/adoption_list.dart';

// Vet screens
import 'package:pawpal/screens/vet/vet_list_screen.dart';
import 'package:pawpal/screens/vet/vet_appointment_screen.dart';
import 'package:pawpal/screens/vet/vet_appointment_summary_screen.dart';

// Auth + onboarding
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/walkthrough_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verification_screen.dart';

// Profile sub-screens
import 'package:pawpal/screens/profile/edit_profile_screen.dart';
import 'package:pawpal/screens/profile/profile_faq_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Robust Firebase init (safe for hot restart)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
    Firebase.app();
  }

  // 🔐 Crashlytics global wiring (errors & zones)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Non-Flutter (platform) errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set user id when logged in (listen once at startup)
  final auth = FirebaseAuth.instance;
  auth.authStateChanges().listen((user) async {
    if (user != null) {
      await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
      await FirebaseCrashlytics.instance.setCustomKey('user_email', user.email ?? '');
    } else {
      await FirebaseCrashlytics.instance.setUserIdentifier('anonymous');
    }
  });

  // ✅ Skip notifications on web (prevents SW errors/white screen)
  if (!kIsWeb) {
    await NotificationService.I.init();
  }

  // Run inside zone so uncaught async errors are captured
  runZonedGuarded(
        () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FavouritesProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const PawPalApp(),
      ),
    ),
        (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class PawPalApp extends StatelessWidget {
  const PawPalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF4B8BFF),
        useMaterial3: true,
      ),
      // ✅ add Crashlytics route breadcrumbs
      navigatorObservers: [CrashlyticsObserver()],
      initialRoute: Routes.splash,
      onGenerateRoute: AppRouter.generateRoute,
      onUnknownRoute: (_) => AppRouter.errorRoute('Unknown route'),
    );
  }
}

/// Central place for route names
abstract class Routes {
  static const splash = '/splash';
  static const walkthrough = '/walkthrough';
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';
  static const verify = '/verify';

  static const home = '/home';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const profileFaq = '/profile/faq';

  static const shop = '/shop';
  static const cart = '/cart';
  static const adoption = '/adoption';
  static const veterinarian = '/veterinarian';

  static const vetAppointment = '/vet_appointment';
  static const vetAppointmentSummary = '/vet_appointment_summary';
}

class VetAppointmentArgs {
  final String vetId;
  const VetAppointmentArgs({required this.vetId});
}

class VetAppointmentSummaryArgs {
  final String vetId;
  final String? serviceTitle;
  final double? servicePrice;
  final String? dateLabel;
  final String? timeSlot;

  const VetAppointmentSummaryArgs({
    required this.vetId,
    this.serviceTitle,
    this.servicePrice,
    this.dateLabel,
    this.timeSlot,
  });
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _page(SplashScreen(), settings);
      case Routes.walkthrough:
        return _page(WalkthroughScreen(), settings);
      case Routes.login:
        return _page(LoginScreen(), settings);
      case Routes.register:
        return _page(RegisterScreen(), settings);
      case Routes.forgot:
        return _page(ForgotPasswordScreen(), settings);
      case Routes.verify:
        return _page(VerificationScreen(), settings);

      case Routes.home:
        return _page(HomePage(), settings);
      case Routes.profile:
        return _page(const ProfileScreen(), settings);
      case Routes.profileEdit:
        return _page(const EditProfileScreen(), settings);
      case Routes.profileFaq:
        return _page(ProfileFaqScreen(), settings);

      case Routes.shop:
        return _page(ShopScreen(), settings);
      case Routes.cart:
        return _page(CartScreen(), settings);
      case Routes.adoption:
        return _page(AdoptionListScreen(), settings);
      case Routes.veterinarian:
        return _page(VetListScreen(), settings);

      case Routes.vetAppointment: {
        final args = settings.arguments;
        if (args is VetAppointmentArgs) {
          return _page(VetAppointmentScreen(vetId: args.vetId), settings);
        } else if (args is Map) {
          final vetId = args['vetId'] as String?;
          if (vetId != null) {
            return _page(VetAppointmentScreen(vetId: vetId), settings);
          }
        }
        return errorRoute('Missing or invalid arguments for ${Routes.vetAppointment}.');
      }

      case Routes.vetAppointmentSummary: {
        final args = settings.arguments;
        if (args is VetAppointmentSummaryArgs) {
          return _page(
            VetAppointmentSummaryScreen(
              vetId: args.vetId,
              serviceTitle: args.serviceTitle,
              servicePrice: args.servicePrice,
              dateLabel: args.dateLabel,
              timeSlot: args.timeSlot,
            ),
            settings,
          );
        } else if (args is Map) {
          final vetId = args['vetId'] as String?;
          if (vetId != null) {
            return _page(
              VetAppointmentSummaryScreen(
                vetId: vetId,
                serviceTitle: args['serviceTitle'] as String?,
                servicePrice: (args['servicePrice'] as num?)?.toDouble(),
                dateLabel: args['dateLabel'] as String?,
                timeSlot: args['timeSlot'] as String?,
              ),
              settings,
            );
          }
        }
        return errorRoute('Missing or invalid arguments for ${Routes.vetAppointmentSummary}.');
      }

      default:
        return errorRoute('No route defined for ${settings.name}');
    }
  }

  static MaterialPageRoute _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);

  static MaterialPageRoute errorRoute(String message) =>
      MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Routing Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(message, textAlign: TextAlign.center),
            ),
          ),
        );
      });
}
