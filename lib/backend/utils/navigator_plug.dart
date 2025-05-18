import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../language/language_controller.dart';
import 'maintenance/maintenance_dialog.dart';


class NavigatorPlug {
  StreamSubscription<bool>? _subscription;
  StreamSubscription<bool>? _maintenanceSubscription;
  bool _timerStarted = false;

  void startListening({
    required int seconds,
    required VoidCallback onChanged,
  }) {
    _subscription = Get.find<LanguageSettingController>().isLoadingValue.stream.listen(
          (isLoading) {
        _checkStatus(seconds, onChanged);
      },
    );

    _maintenanceSubscription =
        Get.find<SystemMaintenanceController>().maintenanceStatus.listen(
              (inMaintenance) {
            _checkStatus(seconds, onChanged);
          },
        );
  }

  void _checkStatus(int seconds, VoidCallback onChanged) {
    if (!_timerStarted &&
        !Get.find<LanguageSettingController>().isLoadingValue.value &&
        Get.find<SystemMaintenanceController>().maintenanceStatus.value ==
            false) {
      _timerStarted = true;

      Timer(
        Duration(seconds: seconds),
            () {
          if (!Get.find<LanguageSettingController>().isLoadingValue.value &&
              Get.find<SystemMaintenanceController>().maintenanceStatus.value ==
                  false) {
            _subscription?.cancel();
            _maintenanceSubscription?.cancel();
            onChanged();
          } else {
            _timerStarted = false;
          }
        },
      );
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _maintenanceSubscription?.cancel();
  }
}