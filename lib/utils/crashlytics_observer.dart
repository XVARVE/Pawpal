import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Logs navigation events into Crashlytics and sets a 'route' custom key.
/// Safe to include on all platforms; no-ops on web.
class CrashlyticsObserver extends NavigatorObserver {
  CrashlyticsObserver();

  void _setRouteKey(String name) {
    if (kIsWeb) return;
    FirebaseCrashlytics.instance.setCustomKey('route', name);
  }

  void _log(String message) {
    if (kIsWeb) return;
    FirebaseCrashlytics.instance.log(message);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name ?? route.runtimeType.toString();
    _setRouteKey(name);
    _log('didPush -> $name');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final name = previousRoute?.settings.name ?? previousRoute?.runtimeType.toString() ?? 'unknown';
    _setRouteKey(name);
    _log('didPop -> back to $name');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final name = newRoute?.settings.name ?? newRoute?.runtimeType.toString() ?? 'unknown';
    _setRouteKey(name);
    _log('didReplace -> $name');
  }
}
