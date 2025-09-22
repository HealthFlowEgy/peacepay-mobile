import 'package:get/get.dart';

import '../controller/auth/forgot_otp_controller.dart';
import '../controller/dashboard/profiles/change_password_controller.dart';

class ForgotOTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChangePasswordController());
    Get.put(ForgotOTPController());
  }
}
