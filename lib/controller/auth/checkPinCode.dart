import 'package:get/get.dart';

import '../../backend/backend_utils/custom_snackbar.dart';
import '../../backend/models/auth/checkPinModel.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
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

        // API: { "message": { "success": ["PIN success!"] }, "data": null }
        final msg = _checkPinModel!.firstSuccessMessage ?? "PIN verified successfully";
        CustomSnackBar.success(msg);

        // Navigate
        // Get.toNamed(nextRoute);
        if (screenIndex == 0) {
          Get.offAllNamed(Routes.addMoneyScreen);
        } else if (screenIndex == 1) {
          Get.offAllNamed(Routes.moneyOutScreen);
        }else if (screenIndex == 2) {
          Get.offAllNamed(Routes.transactionsScreen);
      }else if (screenIndex == 3) {
          Get.offAllNamed(Routes.dashboardScreen);
        }
      } else {
        error.value = "Failed to verify PIN";
      }
    } catch (e) {
      log.e("🐞🐞🐞 Controller error in checkPinProcess ==> $e 🐞🐞🐞");
      error.value = "Error while verifying PIN";
    } finally {
      _isLoading.value = false;
      update();
    }

    return _checkPinModel;
  }
}