import 'package:peacepay/backend/local_storage/local_storage.dart';
import 'package:get/get.dart';

import '../../backend/local_auth/local_auth_controller.dart';
import '../../backend/utils/navigator_plug.dart';
import '../../routes/routes.dart';
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
import 'package:get/get.dart';

import '../../backend/local_storage/local_storage.dart';
import '../../routes/routes.dart';
import '../auth/login_controller.dart';
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _boot();
  }

  Future<void> _boot() async {
    // small splash pause
    await Future.delayed(const Duration(seconds: 1));

    // 1) Onboarding first
    if (!LocalStorage.isOnBoardDone() ) {
      Get.offAllNamed(Routes.onboardScreen);
      return;
    }

    // 2) If not logged in -> Login
    if (!LocalStorage.isLoggedIn()) {
      Get.offAllNamed(Routes.loginScreen);
      return;
    }

    // 3) Logged in -> let BiometricController decide (Create PIN / Check PIN / Dashboard with biometrics)
    final bio = Get.find<BiometricController>(); // make sure it's registered in main()
    await bio.gateIntoApp();
  }
}

