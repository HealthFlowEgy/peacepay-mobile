import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../language/language_controller.dart';
import 'maintenance/maintenance_dialog.dart';

class NavigatorPlug {
  StreamSubscription<bool>? _langSub;
  StreamSubscription<bool>? _maintSub;
  Timer? _timer;
  bool _timerStarted = false;

  void startListening({
    required int seconds,
    required VoidCallback onChanged,
  }) {
    final lang = Get.find<LanguageSettingController>();
    final sys = Get.find<SystemMaintenanceController>();

    // Listen to language loading changes
    _langSub = lang.isLoadingRx.listen((_) {
      _checkStatus(seconds, onChanged, lang, sys);
    });

    // Listen to maintenance status changes (assumed RxBool)
    _maintSub = sys.maintenanceStatus.listen((_) {
      _checkStatus(seconds, onChanged, lang, sys);
    });

    // Kick once in case both are already ready
    _checkStatus(seconds, onChanged, lang, sys);
  }

  void _checkStatus(
    int seconds,
    VoidCallback onChanged,
    LanguageSettingController lang,
    SystemMaintenanceController sys,
  ) {
    final ready = !lang.isLoading && (sys.maintenanceStatus.value == false);

    if (!_timerStarted && ready) {
      _timerStarted = true;

      _timer?.cancel();
      _timer = Timer(Duration(seconds: seconds), () {
        final stillReady =
            !lang.isLoading && (sys.maintenanceStatus.value == false);

        if (stillReady) {
          _langSub?.cancel();
          _maintSub?.cancel();
          onChanged();
        } else {
          // conditions changed during wait; allow retry later
          _timerStarted = false;
        }
      });
    }
  }

  void stopListening() {
    _timer?.cancel();
    _langSub?.cancel();
    _maintSub?.cancel();
    _timerStarted = false;
  }
}
