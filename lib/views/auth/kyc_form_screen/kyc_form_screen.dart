import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';
import '../../../controller/auth/kyc_form_controller.dart';
import '../../../widgets/others/app_icon_widget.dart';
import '../../../widgets/text_labels/title_sub_title_widget.dart';

/// KYCFormScreen
/// Handles display and submission of the KYC (Know Your Customer) verification form.
/// Uses GetX for state management and dynamically renders form fields fetched from the backend.
class KYCFormScreen extends StatelessWidget {
  KYCFormScreen({super.key});

  final controller = Get.put(KYCFormController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const PrimaryAppBar(title: Strings.kycForm),
          body: GetBuilder<KYCFormController>(
            builder: (controller) {
              // Show loader while fetching KYC data
              if (controller.isLoading) {
                return const CustomLoadingWidget();
              }

              return Column(
                children: [
                  const AppIconWidget(),

                  // Observe the `showForm` state to switch between status view and form view
                  Obx(() {
                    if (controller.showForm.value) {
                      // KYC form view (used when user re-applies or initially submits)
                      return Expanded(
                        child: Column(
                          children: [
                            _inputWidget(context),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeHorizontal * .5,
                              ),
                              child: Obx(
                                    () => controller.isSubmitLoading
                                    ? const CustomLoadingWidget()
                                    : PrimaryButton(
                                  title: Strings.submit,
                                  onPressed: () =>
                                      controller.onSubmitProcess(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // KYC status view (default state)
                    return _bottomBodyWidget(context);
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Displays the user's current KYC status, rejection reason, and option to reapply if needed.
  Widget _bottomBodyWidget(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: CustomColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius * 3),
            topRight: Radius.circular(Dimensions.radius * 3),
          ),
        ),
        child: Obx(() {
          final kycStatus = controller.currentKycStatus.value;

          return ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const TitleSubTitleWidget(
                  title: Strings.kycFormTitle,
                  subTitle: Strings.kycFormSubTitle,
                ),
              ),

              /// If user hasn't completed KYC yet → show form directly
              (kycStatus == 0)
                  ? Column(
                children: [
                  verticalSpace(Dimensions.paddingSizeVertical * 1),
                  _inputWidget(context),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeHorizontal * .5,
                    ),
                    child: Obx(
                          () => controller.isSubmitLoading
                          ? const CustomLoadingWidget()
                          : PrimaryButton(
                        title: Strings.submit,
                        onPressed: () =>
                            controller.onSubmitProcess(context),
                      ),
                    ),
                  ),
                ],
              )

              /// Otherwise → show current KYC status and actions
                  : Column(
                children: [
                  // Current KYC status badge (e.g., Verified, Pending, Rejected)
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeHorizontal * .7,
                      vertical: Dimensions.paddingSizeVertical * .7,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeHorizontal * .7,
                      vertical: Dimensions.paddingSizeVertical * .7,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius:
                      BorderRadius.circular(Dimensions.radius * 1.5),
                    ),
                    child: TitleHeading1Widget(
                      text: controller
                          .kycModel.data.kycStringStatus.value
                          .toString(),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  // If rejected → show reason and reapply button
                  if (kycStatus == 3)
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TitleHeading2Widget(
                                color: CustomColor.primaryLightColor,
                                text: "Reason:",
                              ),
                              TitleHeading3Widget(
                                text: controller
                                    .kycModel.data.rejectReason!
                                    .tr,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),

                        /// Button to reapply for verification
                        GestureDetector(
                          onTap: () async {
                            controller.clearKycFields();
                            controller.showForm.value = true;
                            await controller.kycInfoFetch();
                            controller.update();
                          },
                          child: Container(
                            width: 200.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: TitleHeading3Widget(
                                text: 'Reapply for Verification',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Dynamic KYC form builder - generates inputs and file upload fields
  /// based on the backend configuration.
  Widget _inputWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * .7,
        vertical: Dimensions.paddingSizeVertical * .7,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * .7,
        vertical: Dimensions.paddingSizeVertical * .7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Dynamically generated text/field inputs
            ...controller.inputFields,
            verticalSpace(Dimensions.marginBetweenInputBox),

            // File upload fields grid
            if (controller.inputFileFields.isNotEmpty)
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: .99,
                ),
                itemCount: controller.inputFileFields.length,
                itemBuilder: (context, index) =>
                controller.inputFileFields[index],
              ),
          ],
        ),
      ),
    );
  }
}
