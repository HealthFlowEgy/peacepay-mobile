import 'package:get/get.dart';

class CheckPinController extends GetxController {
  var pin = ''.obs;
  var isPinObscured = true.obs;
  var error = RxnString();

  void setPin(String value) {
    pin.value = value;
    error.value = null;
  }

  void togglePinVisibility() {
    isPinObscured.value = !isPinObscured.value;
  }

  void checkPinProcess() {
    if (pin.value.length < 6) {
      error.value = "PIN must be 6 digits";
      return;
    }

  }
}
