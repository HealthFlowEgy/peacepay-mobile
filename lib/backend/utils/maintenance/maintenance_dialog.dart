    // ignore_for_file: deprecated_member_use
import 'package:restart_app/restart_app.dart';

import '../../../utils/basic_screen_imports.dart';
import 'maintenance_model.dart';

class SystemMaintenanceController extends GetxController {
  RxBool maintenanceStatus = false.obs;
}

class MaintenanceDialog {
  show({required MaintenanceModel maintenanceModel}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          Restart.restartApp();
          return false;
        },
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Get.isDarkMode
                ? CustomColor.primaryDarkScaffoldBackgroundColor
                : CustomColor.primaryLightScaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.marginSizeHorizontal * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: Dimensions.marginSizeVertical * 0.5,
                  ),
                  child: Image.network(
                    "${maintenanceModel.data.baseUrl}/${maintenanceModel.data.imagePath}/${maintenanceModel.data.image}",
                  ),
                ),
                Text(
                  maintenanceModel.data.title,
                  style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                      color: CustomColor.blackColor
                  ),
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: Dimensions.marginSizeVertical * 0.5,
                  ),
                  child: Text(
                    maintenanceModel.data.details,
                    style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                        color: CustomColor.blackColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    "Restart",
                    style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                      color: CustomColor.blackColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Restart.restartApp();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
