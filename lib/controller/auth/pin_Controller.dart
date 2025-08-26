import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

import '../../backend/models/auth/createPinModel.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';

class PinController extends GetxController {
  var pin = ''.obs;
  var confirmPin = ''.obs;
  var error = RxnString();

  var isPinObscured = true.obs;
  var isConfirmPinObscured = true.obs;

  void setPin(String val) {
    pin.value = val;
    error.value = null;
  }

  void setConfirmPin(String val) {
    confirmPin.value = val;
    error.value = null;
  }

  void togglePinVisibility() {
    isPinObscured.value = !isPinObscured.value;
  }

  void toggleConfirmPinVisibility() {
    isConfirmPinObscured.value = !isConfirmPinObscured.value;
  }

  void validateAndSubmit() {
    if (pin.value.length != 6) {
      error.value = "PIN must be exactly 6 digits";
      return;
    }
    if (confirmPin.value.length != 6) {
      error.value = "Confirm PIN must be exactly 6 digits";
      return;
    }
    if (pin.value != confirmPin.value) {
      error.value = "PIN codes do not match";
      return;
    }
    error.value = null;
    Get.snackbar("Success", "PIN set successfully!",
        snackPosition: SnackPosition.BOTTOM);
  }
  final pinCodeController = TextEditingController();
  final current_pin_codeController = TextEditingController();
  final pin_code_confirmationController = TextEditingController();
  late CreatePinModel _createPinModel;
  CreatePinModel get registrationModel => _createPinModel;
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  dynamic phoneNumber;
  Future<CreatePinModel> createPinProcess() async {
    validateAndSubmit();
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'pin_code': pin.value,
      // 'current_pin_code':'44444',
      'pin_code_confirmation': confirmPin.value,
    };

    await ApiServices.createPINApi(body: inputBody).then((value) {
      _createPinModel = value!;
       Get.toNamed(Routes.dashboardScreen);
      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isLoading.value = false;
    update();
    return _createPinModel;
  }
}
