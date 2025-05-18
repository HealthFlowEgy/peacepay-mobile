import 'package:adescrow_app/backend/local_storage/local_storage.dart';
import 'package:get/get.dart';

import '../../backend/local_auth/local_auth_controller.dart';
import '../../backend/utils/navigator_plug.dart';
import '../../routes/routes.dart';

class SplashController extends GetxController {

  final navigatorPlug = NavigatorPlug();

  @override
  void onReady() {
    super.onReady();
    navigatorPlug.startListening(
      seconds: 3,
      onChanged: () {
        LocalStorage.isLoggedIn()
            ? Get.find<BiometricController>().supportState == SupportState.supported
            ? Get.offAllNamed(Routes.welcomeScreen)
            :  Get.offAllNamed(Routes.loginScreen)
            : LocalStorage.isOnBoardDone()
            ? Get.offAllNamed(Routes.onboardScreen)
            : Get.offAllNamed(Routes.onboardScreen);
      },
    );
  }

  @override
  void onClose() {
    navigatorPlug.stopListening();
    super.onClose();
  }
}