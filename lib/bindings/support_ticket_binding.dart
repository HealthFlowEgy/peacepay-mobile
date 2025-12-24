import 'package:get/get.dart';

import '../controller/dashboard/btm_navs_controller/profile_controller.dart';

class SupportTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController(), permanent: false);
  }
}
