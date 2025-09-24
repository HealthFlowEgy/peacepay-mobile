import 'package:get/get.dart';

import '../../backend/backend_utils/custom_snackbar.dart';
import '../../backend/local_storage/local_storage.dart';
import '../../backend/models/auth/checkPinModel.dart';
import '../../backend/models/auth/forgot_send_otp_model.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../dashboard/profiles/update_profile_controller.dart';
class CheckPinController extends GetxController {
  // --- State
  final RxString pin = ''.obs;
  final RxBool isPinObscured = true.obs;
  final RxnString error = RxnString();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  CheckPinModel? _checkPinModel;

  // --- Actions
  void setPin(String value) {
    // keep only digits + trim and max 6 chars
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '').trim();
    pin.value = digitsOnly.length > 6 ? digitsOnly.substring(0, 6) : digitsOnly;
    error.value = null;
    update();
  }

  void togglePinVisibility() {
    isPinObscured.value = !isPinObscured.value;
    update();
  }

  Future<CheckPinModel?> checkPinProcess({required int screenIndex}) async {
    // local validation
    if (pin.value.length != 6) {
      error.value = "PIN must be 6 digits";
      update();
      return null;
    }

    _isLoading.value = true;
    update();

    final Map<String, dynamic> inputBody = {
      'pin_code': pin.value,
    };

    try {
      final value = await ApiServices.checkPINApi(body: inputBody);
      if (value != null) {
        _checkPinModel = value;
        Get.back(result: true);
        final msg = _checkPinModel!.firstSuccessMessage ?? "PIN verified successfully";
        // CustomSnackBar.success(msg);

        if (screenIndex == 0) {
          Get.offAllNamed(Routes.addMoneyScreen);
          LocalStorage.saveLastRoute(Routes.addMoneyScreen);
        } else if (screenIndex == 1) {
          Get.offAllNamed(Routes.moneyOutScreen);
          LocalStorage.saveLastRoute(Routes.moneyOutScreen);
        } else if (screenIndex == 2) {
          Get.offAllNamed(Routes.transactionsScreen);
          LocalStorage.saveLastRoute(Routes.transactionsScreen);
        } else if (screenIndex == 3) {
          // Get.offAllNamed(Routes.dashboardScreen);
          // LocalStorage.saveHasPin(hasPin: true);
          // LocalStorage.saveLastRoute(Routes.dashboardScreen);
          Get.offAllNamed(Routes.dashboardScreen);
          LocalStorage.saveHasPin(hasPin: true);
          LocalStorage.setFirstLoginDone(true); //
          LocalStorage.saveLastRoute(Routes.dashboardScreen);
        }
      } else {
        error.value = "Failed to verify PIN";
      }
    } catch (e) {
      error.value = "Error while verifying PIN";
    } finally {
      _isLoading.value = false;
      update();
    }

    return _checkPinModel;
  }

  final _isForgotLoading = false.obs;
  bool get isForgotLoading => _isForgotLoading.value;

  late ForgetSendOtpModel? _forgotModel;
  ForgetSendOtpModel? get forgotModel => _forgotModel;

  late RxString token;
  Future<ForgetSendOtpModel?> sendOTPProcess() async {
    _isForgotLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'credentials': Get.find<UpdateProfileController>()
          .profileModel
          .data
          .user.mobile,
    };

    await ApiServices.forgotPinSendOTPApi(body: inputBody).then((value) {
      _forgotModel = value!;
      token = _forgotModel!.data.token.obs;
      Get.toNamed(Routes.forgotOTPScreen);
      update();
    }).catchError((onError) {
    });

    _isForgotLoading.value = false;
    update();
    return _forgotModel;
  }
  Future<ForgetSendOtpModel?> sendOTPProcessBeforePin() async {

    _isForgotLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'credentials': Get.find<UpdateProfileController>()
          .profileModel
          .data
          .user.mobile,
    };

    await ApiServices.forgotPinSendOTPApi(body: inputBody).then((value) {
      _forgotModel = value!;
      token = _forgotModel!.data.token.obs;
      Get.toNamed(Routes.forgotOTPScreen,arguments: 'beforeLogin');
      update();
    }).catchError((onError) {
    });

    _isForgotLoading.value = false;
    update();
    return _forgotModel;
  }
  void onForgotPassProcess() async{
    await sendOTPProcess().then((value) {
      if(value != null) {
      }
    });

  }
  void onForgotPassProcessBeforePin() async{
    await sendOTPProcessBeforePin().then((value) {
      if(value != null) {
      }
    });

  }
}