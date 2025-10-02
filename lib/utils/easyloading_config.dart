import 'package:flutter_easyloading/flutter_easyloading.dart';

class EasyLoadingConfig {
  static void applyDefaults() {
    final i = EasyLoading.instance;

    // Visuals
    i
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..maskType = EasyLoadingMaskType.black
      ..userInteractions = false
      ..dismissOnTap = false
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..indicatorSize = 42.0
      ..radius = 10.0;

    // Texts
    i
      ..displayDuration = const Duration(milliseconds: 1500);
  }
}
