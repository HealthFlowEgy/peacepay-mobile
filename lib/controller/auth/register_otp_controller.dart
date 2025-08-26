import 'dart:async';

import 'package:adescrow_app/backend/backend_utils/custom_snackbar.dart';
import 'package:adescrow_app/backend/models/auth/registration_model.dart';
import 'package:adescrow_app/controller/auth/register_controller.dart';

import '../../backend/backend_utils/logger.dart';
import '../../backend/local_storage/local_storage.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../../utils/basic_screen_imports.dart';

final log = logger(RegisterOTPController);

class RegisterOTPController extends GetxController {
  final pinController = TextEditingController();
  // final mobileController = TextEditingController();


  @override
  void dispose() {
    pinController.dispose();
    // mobileController.dispose();
    timer!.cancel();
    super.dispose();
  }

  Timer? timer;
  RxInt second = 60.obs;
  RxBool enableResend = false.obs;

  @override
  void onInit() {
    timerInit();
    super.onInit();
  }

  resendBTN() async {
    await resendOTPProcess();
  }

  timerInit() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (second.value != 0) {
        second.value--;
      } else {
        enableResend.value = true;
      }
    });
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  otpSubmitProcess({String ?mobileNum}) async {
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {"code": pinController.text,
      "mobile":mobileNum};
    await ApiServices.emailVerificationApi(body: inputBody).then((value) {
      if (value != null) {
        if(Get.find<RegisterController>().registrationModel.data.user.kycVerified == 0) {
          Get.toNamed(Routes.kycFormScreen);
        }else{
          Get.offAllNamed(Routes.dashboardScreen);
        }
      }
      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isLoading.value = false;
    update();
  }

  resendOTPProcess() async {
    // _isLoading.value = true;
    // update();

    await ApiServices.signUpResendOtpApi().then((value) {
      if (value != null) {
        second.value = 59;
        enableResend.value = false;
      }

      update();
    }).catchError((onError) {
      log.e(onError);
    });

    // _isLoading.value = false;
    // update();
  }

  void onOTPSubmitProcess({required mobileNum}) async {
    if (pinController.text.length == 6) {
      await otpSubmitProcess(mobileNum: mobileNum);


        LocalStorage.isLoginSuccess(isLoggedIn: true);
        LocalStorage.saveEmail(email: mobileNum);
        Get.offAllNamed(Routes.dashboardScreen);

    } else {
      CustomSnackBar.error(Strings.enterPin);
    }
  }
}
