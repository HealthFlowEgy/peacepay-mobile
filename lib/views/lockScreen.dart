import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../backend/services/inactive_services.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final _auth = LocalAuthentication();
  bool _authInProgress = false;
  bool _triedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate(); // auto-prompt on open
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-prompt when coming back to foreground while still locked
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        InactivityService().isLocked &&
        !_authInProgress) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_authInProgress) return;
    _authInProgress = true;
    try {
      final supported = await _auth.isDeviceSupported();
      // Note: canCheckBiometrics can be false while device PIN exists; that’s OK.
      if (!supported) {
        _showInfo('This device does not support secure authentication.');
        return;
      }

      final ok = await _auth.authenticate(
        localizedReason: 'Unlock with biometrics or device passcode',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,   // 👈 allows device PIN/Pattern/Passcode fallback
          useErrorDialogs: true,
        ),
      );

      if (ok) {
        InactivityService().unlock();
        Get.back(); // Return to the exact previous route & state
      }
    } catch (e) {
      _showInfo('Authentication unavailable. Ensure a device PIN/passcode is set.');
    } finally {
      _authInProgress = false;
      if (mounted) setState(() => _triedOnce = true);
    }
  }

  void _showInfo(String msg) {
    Get.showSnackbar(GetSnackBar(message: msg, duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // prevent bypass via back
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Locked', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('Authenticate to continue'),
                const SizedBox(height: 24),
                if (_triedOnce)
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Try again'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
