import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../backend/local_storage/local_storage.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../controller/before_auth/basic_settings_controller.dart';
import '../../../controller/dashboard/btm_navs_controller/profile_controller.dart';
import '../../../controller/dashboard/profiles/update_profile_controller.dart';
import '../../../routes/routes.dart';
import '../../../widgets/dialog_helper.dart';
import '../../../widgets/list_tile/drawer_tile_button_widget.dart';
import '../../../widgets/list_tile/profile_tile_button_widget.dart';
import '../../../widgets/others/profile_image_widget.dart';
import '../../../widgets/buttons/switch_button_widget.dart';
import '../../web_view/web_view_screen.dart';
import '../profiles_screens/support_ticket_screen.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _profilesWidget(context),
              _tilesWidget(context),
            ],
          )),
    );
  }

  _profilesWidget(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const ProfileImageWidget(
                    isCircle: false,
                  ),
                  verticalSpace(Dimensions.marginSizeVertical * .7),
                  TitleHeading3Widget(
                    text: Get.find<UpdateProfileController>()
                        .profileModel
                        .data
                        .user
                        .mobile,
                    fontSize: Dimensions.headingTextSize3 * .9,
                    color: Theme.of(context).primaryColor,
                  ).animate().fadeIn(duration: 900.ms, delay: 300.ms).move(
                      begin: const Offset(-16, 0), curve: Curves.easeOutQuad),
                  verticalSpace(Dimensions.marginSizeVertical * .5),
                  SwitchButtonWidget(
                    onTap: (selectedThemeKey,)async {
                      // debugPrint(value.toString());
                      await Get.find<UpdateProfileController>().profileSwitch(
                        selectedThemeKey
                      );
                      // Additional logic if needed
                    },
                  ),
                  // SwitchButtonWidget(
                  //   onTap: (bool value) async{
                  //     debugPrint(value.toString());
                  //       await Get.find<UpdateProfileController>().profileSwitch();
                  //   },
                  // ),
                  verticalSpace(Dimensions.marginSizeVertical * .8),
                ],
              ))
    ;
  }

  _tilesWidget(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHorizontal * 1.5,
            vertical: Dimensions.paddingSizeHorizontal * 1.0,
          ),
          decoration: BoxDecoration(
              color: CustomColor.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius * 3),
                topRight: Radius.circular(Dimensions.radius * 3),
              )),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: AnimateList(
                children: [
                  ProfileTileButtonWidget(
                    onTap: controller.routeUpdateProfile,
                    text: Strings.updateProfile,
                    icon: Icons.account_circle_outlined,
                  ),
                  Visibility(
                    // visible: Get.find<BasicSettingsController>().basicSettingModel.data.kycStatus == 0,
                    child: ProfileTileButtonWidget(
                      onTap: controller.routeUpdateKYC,
                      text: Strings.updateKycForm,
                      icon: Icons.article_outlined,
                    ),
                  ),
                  // ProfileTileButtonWidget(
                  //   onTap: controller.routeFASecurity,
                  //   text: Strings.faSecurity,
                  //   icon: Icons.security_outlined,
                  // ),
                  ProfileTileButtonWidget(
                    onTap: controller.routeChangePassword,
                    text: Strings.changePassword,
                    icon: Icons.lock_outline,
                  ),
                  // DrawerTileButtonWidget(
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const WebViewScreen(
                  //               appTitle: Strings.helpCenter,
                  //               link: "https://peacepay.me/help-center",
                  //             )));
                  //   },
                  //   text: Strings.helpCenter,
                  //   icon: Icons.help_outline_rounded,
                  // ),
                  DrawerTileButtonWidget(
                      onTap: () {
                        Get.toNamed(Routes.supportTicket);
                          },
                    text: 'Contact Support',
                    icon: Icons.support_agent,
                  ),
                  DrawerTileButtonWidget(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WebViewScreen(
                                appTitle: 'Support Center',
                                link: "https://peacepay.me/tutorials",
                              )));
                    },
                    text: 'Tutorials',
                    icon: Icons.help_outline,
                  ),
                  DrawerTileButtonWidget(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WebViewScreen(
                                appTitle: Strings.privacyPolicy,
                                link: "https://peacepay.me/privacy",
                              )));
                    },
                    text: Strings.privacyPolicy,
                    icon: Icons.privacy_tip_outlined,
                  ),
                  DrawerTileButtonWidget(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WebViewScreen(
                                appTitle: Strings.termsOfUse,
                                link: "https://peacepay.me/terms-and-conditions",
                              )));
                    },
                    text: Strings.termsOfUse,
                    icon: Icons.info_outline,
                  ),
                  Obx(() => controller.isLoading.value
                      ? const CustomLoadingWidget()
                      : DrawerTileButtonWidget(
                    onTap: () {
                      DialogHelper.showAlertDialog(context,
                          title: Strings.logout,
                          content: Strings.logOutContent, onTap: () async {
                            Get.close(1);
                            await controller.logOutProcess();
                          });
                    },
                    text: Strings.logout,
                    icon: Icons.power_settings_new_outlined,
                  )),
                  Obx(() => controller.isLoading.value
                      ? const CustomLoadingWidget()
                      : ProfileTileButtonWidget(
                          onTap: () {
                            DialogHelper.showAlertDialog(context,
                                title: Strings.deleteAccount,
                                content: Strings.deleteAccountContent, onTap: () async{
                              Get.close(1);
                              await controller.deleteProfileProcess();
                            });
                          },
                          text: Strings.deleteAccount,
                          icon: Icons.delete_outlined,
                          isDelete: true,
                        )),
                ],
              ),
            ),
          ),
        ));
  }
}
