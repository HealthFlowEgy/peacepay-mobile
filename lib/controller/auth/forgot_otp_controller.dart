import 'dart:async';
import 'dart:convert';

import 'package:peacepay/controller/auth/reset_password_controller.dart';

import '../../backend/backend_utils/custom_snackbar.dart';
import '../../backend/backend_utils/logger.dart';
import '../../backend/models/auth/forgotPinVerifyOTPModel.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../../utils/basic_screen_imports.dart';
import '../dashboard/profiles/change_password_controller.dart';
import 'checkPinCode.dart';
import 'login_controller.dart';

final log = logger(ForgotOTPController);

class ForgotOTPController extends GetxController {
  final pinController = TextEditingController();

  @override
  void dispose() {
    pinController.dispose();
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
    Get.find<LoginController>().sendOTPProcess().then((value) {
      if (value != null) {
        second.value = 59;
        enableResend.value = false;
      }
    });
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

  final _isForgotLoading = false.obs;
  bool get isForgotLoading => _isForgotLoading.value;
  late ForgetPinVerifyOtpModel? _modelData;
  ForgetPinVerifyOtpModel? get modelData => _modelData;

  // Get.find<ChangePasswordController>().forgotModel!.data.token
  verifyOTPProcess() async {
    _isForgotLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'otp': pinController.text,
      // 'otp': '123456',
      'token': Get.find<ChangePasswordController>().forgotModel!.data.token
    };
    await ApiServices.forgotPasswordVerifyOTPApi(body: inputBody).then((value) {
      if (value != null) {
        _modelData = value;
        Get.put(ResetPasswordController());
        Get.toNamed(Routes.resetPassScreen);
      } else {
        // Only fallback if post() didn’t send an error already
        CustomSnackBar.error("Verification Otp is Invalid");
      }
      update();
    }).catchError((onError) {
      try {
        final parsed = jsonDecode(onError.toString());
        final msg = parsed["message"]?["error"]?[0] ?? "Something went wrong.";
        CustomSnackBar.error(msg);
      } catch (_) {
        CustomSnackBar.error(onError.toString());
      }
    });

    _isForgotLoading.value = false;
    update();
  }

  verifyOTPProcessBeforeLogin() async {
    _isForgotLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'otp': pinController.text,
      // 'otp': '123456',
      'token': Get.find<CheckPinController>().forgotModel!.data.token
    };
    await ApiServices.forgotPasswordVerifyOTPApi(body: inputBody).then((value) {
      if (value != null) {
        _modelData = value;
        Get.put(ResetPasswordController());
        Get.toNamed(Routes.resetPassScreen);
      } else {
        // Only fallback if post() didn’t send an error already
        CustomSnackBar.error("Verification Otp is Invalid");
      }
      update();
    }).catchError((onError) {
      try {
        final parsed = jsonDecode(onError.toString());
        final msg = parsed["message"]?["error"]?[0] ?? "Something went wrong.";
        CustomSnackBar.error(msg);
      } catch (_) {
        CustomSnackBar.error(onError.toString());
      }
    });

    _isForgotLoading.value = false;
    update();
  }

  void onOTPSubmitProcess() async {
    Get.put(CheckPinController());
    Get.put(LoginController());
    if (pinController.text.length == 4) {
      await verifyOTPProcess();
    } else {
      CustomSnackBar.error(Strings.enterPin);
    }
  }

  void onOTPSubmitProcessBeforePin() async {
    Get.put(CheckPinController());
    Get.put(LoginController());
    if (pinController.text.length == 4) {
      await verifyOTPProcessBeforeLogin();
    } else {
      CustomSnackBar.error(Strings.enterPin);
    }
  }
}
