// register_otp_screen.dart
// --------------------------------------------------------------------------------------
// Register OTP Screen (GetX)
// - Uses RegisterOTPController provided by route binding (do NOT put it here).
// - Displays OTP info, PIN input, resend timer, and submit CTA.
// - IMPORTANT: Your PinCodeWidget (pin_code_widget2.dart) MUST set
//   `autoDisposeControllers: false` because we pass a parent-owned controller.
// --------------------------------------------------------------------------------------

import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';

import '../../../controller/auth/register_otp_controller.dart';
import '../../../widgets/buttons/secondary_button.dart';
import '../../../widgets/inputs/pin_code_widget2.dart';
import '../../../widgets/others/app_icon_widget.dart';
import '../../../widgets/text_labels/title_sub_title_widget.dart';

class RegisterOTPScreen extends GetView<RegisterOTPController> {
  final dynamic mobileNumber;
  const RegisterOTPScreen({super.key, this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    // Defensive: keep scaffold background consistent with theme
    return SafeArea(
      child: ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const PrimaryAppBar(
            title: Strings.otpVerification,
          ),
          body: Column(
            children: [
              // Brand / App icon
              const AppIconWidget(),
              // Main content
              _bottomBody(context),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------------------
  // Rounded container containing title, input, timer/resend, and submit
  // ----------------------------------------------------------------------------------
  Widget _bottomBody(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: CustomColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius * 3),
            topRight: Radius.circular(Dimensions.radius * 3),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            // Title / Subtitle
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const TitleSubTitleWidget(
                title: Strings.otpVerification,
                subTitle: Strings.otpVerificationSubTitle,
              ),
            ),

            // PIN input
            _pinInputCard(context),

            verticalSpace(Dimensions.paddingSizeVertical * .3),

            // Resend timer OR Resend button
            Obx(() {
              final canResend = controller.enableResend.value;
              return canResend
                  ? SecondaryButton(
                text: Strings.resend,
                onTap: controller.resendBTN,
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    size: Dimensions.iconSizeDefault * 1.1,
                    color: Theme.of(context).primaryColor,
                  ),
                  horizontalSpace(Dimensions.widthSize * .5),
                  TitleHeading4Widget(
                    text:
                    "00:${controller.second.value < 10 ? "0${controller.second.value}" : controller.second.value}",
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              );
            }),

            verticalSpace(Dimensions.paddingSizeVertical * .8),

            // Submit button (reactive loading)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeHorizontal * .5,
              ),
              child: Obx(
                    () => controller.isLoading
                    ? const CustomLoadingWidget()
                    : PrimaryButton(
                  title: Strings.submit,
                  onPressed: () {
                    // Forward to controller with provided MSISDN
                    controller.onOTPSubmitProcess(
                      mobileNum: (mobileNumber ?? '').toString(),
                    );
                  },
                ),
              ),
            ),

            verticalSpace(Dimensions.paddingSizeVertical * 1.5),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------------------
  // PIN Input Card
  // - Passes parent-owned controller → child MUST NOT auto-dispose it.
  // - Ensure your PinCodeWidget sets `autoDisposeControllers: false`.
  // ----------------------------------------------------------------------------------
  Widget _pinInputCard(BuildContext context) {
    final msisdn = (mobileNumber ?? '').toString(); // safe string
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeHorizontal * .3,
        right: Dimensions.paddingSizeHorizontal * .2,
        top: Dimensions.paddingSizeVertical * .7,
        bottom: Dimensions.paddingSizeVertical * .24,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * .90,
        vertical: Dimensions.paddingSizeVertical * .7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
      ),
      child: PinCodeWidget(
        mobileController: msisdn,
        textController: controller.pinController, // parent-owned
        // NOTE: In PinCodeWidget (pin_code_widget2.dart) you MUST set:
        // autoDisposeControllers: false
      ),
    );
  }
}
