import 'package:peacepay/backend/local_storage/local_storage.dart';
import 'package:get/get.dart';

import '../../backend/local_auth/local_auth_controller.dart';
import '../../language/language_controller.dart';
import '../../routes/routes.dart';
import 'basic_settings_controller.dart';
//
// class SplashController extends GetxController {
//
//   final navigatorPlug = NavigatorPlug();
//
//   @override
//   void onReady() {
//     super.onReady();
//     navigatorPlug.startListening(
//       seconds: 1,
//       onChanged: () {
//         LocalStorage.isLoggedIn()
//             ? Get.find<BiometricController>().supportState == SupportState.supported
//             ? Get.offAllNamed(Routes.loginScreen)
//             // ? Get.offAllNamed(Routes.welcomeScreen)
//             :  Get.offAllNamed(Routes.loginScreen)
//             : LocalStorage.isOnBoardDone()
//             ? Get.offAllNamed(Routes.onboardScreen)
//             : Get.offAllNamed(Routes.onboardScreen);
//       },
//     );
//   }
//
//   @override
//   void onClose() {
//     navigatorPlug.stopListening();
//     super.onClose();
//   }
// }

// lib/controller/splash/splash_controller.dart

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _boot();
  }

  Future<void> _boot() async {
    print('🚀 [SplashController] Starting boot sequence...');

    // Wait for basic settings to load first
    final basicSettings = Get.find<BasicSettingsController>();
    print('⏳ [SplashController] Waiting for basic settings...');

    // Wait until basic settings are loaded
    while (basicSettings.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    print('✅ [SplashController] Basic settings loaded');

    // Wait for language translations to load
    final languageController = Get.find<LanguageSettingController>();
    print('⏳ [SplashController] Waiting for language translations...');

    // Wait until language translations are loaded
    while (languageController.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    print('✅ [SplashController] Language translations loaded');

    // Additional small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 500));

    print('🎯 [SplashController] All initialization complete, navigating...');

    // 1) Onboarding first
    if (!LocalStorage.isOnBoardDone()) {
      print('📍 [SplashController] Navigating to onboard screen');
      Get.offAllNamed(Routes.onboardScreen);
      return;
    }

    // 2) If not logged in -> Login
    if (!LocalStorage.isLoggedIn()) {
      print('📍 [SplashController] Navigating to login screen');
      Get.offAllNamed(Routes.loginScreen);
      return;
    }

    // 3) Logged in -> let BiometricController decide (Create PIN / Check PIN / Dashboard with biometrics)
    print('📍 [SplashController] User logged in, checking biometric auth...');
    final bio =
        Get.find<BiometricController>(); // make sure it's registered in main()
    await bio.gateIntoApp();
  }
}
