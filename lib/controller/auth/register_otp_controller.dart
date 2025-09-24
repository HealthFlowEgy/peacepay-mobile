import 'dart:async';

import 'package:peacepay/backend/backend_utils/custom_snackbar.dart';
import 'package:peacepay/backend/models/auth/registration_model.dart';
import 'package:peacepay/controller/auth/login_controller.dart';
import 'package:peacepay/controller/auth/register_controller.dart';

import '../../backend/backend_utils/logger.dart';
import '../../backend/local_storage/local_storage.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../../utils/basic_screen_imports.dart';
import '../../views/auth/PIN/pINCheckScreen.dart';

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

  otpSubmitProcess({String? mobileNum}) async {
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      "code": pinController.text,
      "mobile": mobileNum,
    };
    await ApiServices.emailVerificationApi(body: inputBody).then((value) async {
      if (value != null) {
        LocalStorage.isLoginSuccess(isLoggedIn: true);
        final hasPinFromServer = Get.find<LoginController>().signInModel.data.user.hasPin;
        await LocalStorage.saveHasPin(hasPin: hasPinFromServer);
        if (hasPinFromServer == false) {
          Get.offAllNamed(Routes.createPINScreen);
        } else {
          Get.offAll(() => CheckPinScreen(index: 3));
        }
      } else {
        CustomSnackBar.error("Verification Otp is Invalid");
      }
      update();
    }).catchError((onError) {
      CustomSnackBar.error(onError.toString());
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
    if (pinController.text.length == 4) {
      await otpSubmitProcess(mobileNum: mobileNum);

      LocalStorage.saveEmail(email: mobileNum);
    } else {
      CustomSnackBar.error(Strings.enterPin);
    }
  }
}
