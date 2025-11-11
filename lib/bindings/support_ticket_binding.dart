import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../controller/dashboard/btm_navs_controller/profile_controller.dart';

class SupportTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController(), permanent: false);
  }
}