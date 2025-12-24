import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';

import '../../../../controller/dashboard/my_wallets/money_out_controller.dart';
import '../../../../widgets/text_labels/title_sub_title_widget.dart';

class MoneyOutManualScreen extends StatelessWidget {
  MoneyOutManualScreen({super.key});

  final controller = Get.put(MoneyOutController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PrimaryAppBar(
            title: controller.information.gatewayCurrencyName,
          ),
          body: _bottomBodyWidget(context),
        ),
      ),
    );
  }

  Widget _bottomBodyWidget(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TitleSubTitleWidget(
              fromStart: true,
              title: Strings.moneyOut,
              subTitle: controller.moneyOutManualModel.data.details,
            ),
          ),
          Column(
            children: [
              verticalSpace(Dimensions.paddingSizeVertical * 0),
              _inputWidget(context),

              // Submit: disabled until a bank is chosen (if a bank dropdown exists)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeHorizontal * .5,
                ),
                child: Obx(() {
                  final modelFields =
                      controller.moneyOutManualModel.data.inputFields;

                  // Prefer a 'select' whose label/name indicates "bank"
                  final bankDropdownField = modelFields.firstWhereOrNull(
                    (f) =>
                        f.type == 'select' &&
                        f.options != null &&
                        (((f.label ?? '').toLowerCase().contains('bank')) ||
                            ((f.name ?? '').toLowerCase().contains('bank'))),
                  );

                  final bankKey = bankDropdownField?.name;
                  final bankChosen = bankKey == null
                      ? true // if there's no bank dropdown in the model, don't block
                      : (controller.selectedValues[bankKey]?.isNotEmpty ==
                          true);

                  final disabled = controller.isLoading || !bankChosen;

                  return AbsorbPointer(
                    absorbing: disabled,
                    child: Opacity(
                      opacity: disabled ? 0.6 : 1.0,
                      child: controller.isLoading
                          ? const CustomLoadingWidget()
                          : PrimaryButton(
                              title: Strings.submit,
                              onPressed: () {
                                if (disabled) return;

                                // Run full form validation (dropdown validator included)
                                final ok = controller.formKey.currentState
                                        ?.validate() ==
                                    true;
                                if (!ok) return;

                                controller.onManualSubmit(context);
                              },
                            ),
                    ),
                  );
                }),
              ),

              verticalSpace(Dimensions.paddingSizeVertical * 1.5),
            ],
          )
        ],
      ),
    );
  }

  Widget _inputWidget(BuildContext context) {
    final modelFields = controller.moneyOutManualModel.data.inputFields;

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
        borderRadius: BorderRadius.circular(Dimensions.radius * 1),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < controller.inputFields.length; i++) ...[
              controller.inputFields[i],
              // If this position corresponds to account/IBAN, render the Bank dropdown after it.
              if (i < modelFields.length)
                if (modelFields[i]
                        .label
                        .toLowerCase()
                        .contains('bank account') ||
                    modelFields[i].label.toLowerCase().contains('iban'))
                  Padding(
                    padding: EdgeInsets.only(
                      top: Dimensions.paddingSizeVertical * 0.7,
                      bottom: Dimensions.paddingSizeVertical * 0.5,
                    ),
                    child: Obx(() {
                      // Prefer a dropdown whose label/name indicates "Bank"
                      final bankField = modelFields.firstWhereOrNull(
                        (f) =>
                            f.type == 'select' &&
                            f.options != null &&
                            (((f.label ?? '').toLowerCase().contains('bank')) ||
                                ((f.name ?? '')
                                    .toLowerCase()
                                    .contains('bank'))),
                      );

                      // Fallback: first select field if no explicit bank field exists
                      final dropdownField = bankField ??
                          modelFields.firstWhereOrNull(
                            (f) => f.type == 'select' && f.options != null,
                          );

                      if (dropdownField == null) return const SizedBox();

                      // Ensure reactive slot
                      controller.selectedValues
                          .putIfAbsent(dropdownField.name, () => '');

                      return DropdownButtonFormField<String>(
                        value: controller.selectedValues[dropdownField.name]
                                    ?.isEmpty ==
                                true
                            ? null
                            : controller.selectedValues[dropdownField.name],

                        // Options from backend
                        items: dropdownField.options!.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),

                        // On change update reactive value
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateSelectedValue(
                                dropdownField.name, value);
                          }
                        },

                        // Label & border
                        decoration: InputDecoration(
                          labelText:
                              "${dropdownField.label.isNotEmpty == true ? dropdownField.label : 'Bank'} *",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius * 1.3,
                            ),
                          ),
                        ),

                        // REQUIRED: user must pick a bank (or whichever select field is used)
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select ${dropdownField.label.toLowerCase() ?? 'bank'}';
                          }
                          return null;
                        },
                      );
                    }),
                  ),
            ],

            // file upload grid
            if (controller.inputFileFields.isNotEmpty)
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: .99,
                ),
                itemCount: controller.inputFileFields.length,
                itemBuilder: (BuildContext context, int index) {
                  return controller.inputFileFields[index];
                },
              ),
          ],
        ),
      ),
    );
  }
}
