// lib/controller/auth/biometric_controller.dart
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../backend/local_storage/local_storage.dart';
import '../../routes/routes.dart';

class BiometricController extends GetxController with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();

  /// cache support state (for UI if needed)
  SupportState supportState = SupportState.unknown;

  /// prevent double navigations
  final RxBool _navigated = false.obs;

  /// keep an "unlocked" session while app is in foreground
  bool _sessionUnlocked = false;

  /// track last unlock method
  UnlockMode _lastUnlockMode = UnlockMode.pin;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // detect hardware support (non-blocking)
    auth.isDeviceSupported().then((isSupported) {
      supportState = isSupported ? SupportState.supported : SupportState.unsupported;
      update();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// lock again when app goes background (optional)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _sessionUnlocked = false;
    }
  }

  /// Splash router
  Future<void> gateIntoApp() async {
    if (_navigated.value) return;

    final loggedIn = LocalStorage.isLoggedIn();
    if (!loggedIn) {
      _go(() => Get.offAllNamed(Routes.loginScreen));
      return;
    }

    final hasPin = LocalStorage.hasPin() == true;
    if (!hasPin) {
      _go(() => Get.offAllNamed(Routes.createPINScreen));
      return;
    }

    // عنده PIN
    final hasBio = await _deviceHasBiometricsReady();

    if (hasBio && _lastUnlockMode == UnlockMode.biometric) {
      // آخر مرة كان فاتح بالبصمة → جرّب البصمة
      final ok = await _authenticateBiometric();
      if (ok) {
        _sessionUnlocked = true;
        _lastUnlockMode = UnlockMode.biometric;
        _go(() => Get.offAllNamed(Routes.dashboardScreen));
        return;
      }
    }

    // في باقي الحالات → لازم يدخل PIN
    _lastUnlockMode = UnlockMode.pin;
    _go(() => Get.offAllNamed(Routes.checkPinScreen, arguments: 3));
  }

  /// Use this to protect any action/screen
  Future<void> requireUnlock({required VoidCallback onUnlocked}) async {
    if (_sessionUnlocked) {
      onUnlocked();
      return;
    }

    final loggedIn = LocalStorage.isLoggedIn();
    if (!loggedIn) {
      Get.offAllNamed(Routes.loginScreen);
      return;
    }

    final hasPin = LocalStorage.hasPin() == true;
    if (!hasPin) {
      await Get.toNamed(Routes.createPINScreen);
      return;
    }

    if (await _deviceHasBiometricsReady() && _lastUnlockMode == UnlockMode.biometric) {
      final ok = await _authenticateBiometric();
      if (ok) {
        _sessionUnlocked = true;
        _lastUnlockMode = UnlockMode.biometric;
        onUnlocked();
        return;
      }
    }

    // fallback → Check PIN
    final result = await Get.toNamed(Routes.checkPinScreen, arguments: 3);
    if (result == true) {
      _sessionUnlocked = true;
      _lastUnlockMode = UnlockMode.pin;
      onUnlocked();
    }
  }

  /// Backward-compat for old calls
  Future<void> showLocalAuth() => requireUnlock(onUnlocked: () {});

  // ---------- Internals ----------
  Future<bool> _deviceHasBiometricsReady() async {
    try {
      final supported = await auth.isDeviceSupported();
      final enrolled = await auth.canCheckBiometrics;
      return supported && enrolled;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _authenticateBiometric() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: false, // no default system dialogs
        ),
      );
    } catch (_) {
      return false;
    }
  }

  void _go(VoidCallback nav) {
    if (_navigated.value) return;
    _navigated.value = true;
    nav();
  }
}

enum SupportState { unknown, supported, unsupported }
enum UnlockMode { pin, biometric }
