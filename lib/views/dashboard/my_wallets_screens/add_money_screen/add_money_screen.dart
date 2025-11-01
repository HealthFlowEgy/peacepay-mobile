import 'package:peacepay/backend/backend_utils/custom_snackbar.dart';
import 'package:peacepay/routes/routes.dart';
import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/text_labels/title_heading5_widget.dart';
import 'package:flutter/services.dart';

import '../../../../backend/models/add_money/add_money_index_model.dart';
import '../../../../controller/dashboard/my_wallets/add_money_controller.dart';
import '../../../../widgets/appbar/back_button.dart';
import '../../../../widgets/custom_dropdown_widget/wallet_dropdown_widget.dart';
import '../../../../widgets/keyboard/keyboard_widget.dart';
import '../../../../widgets/others/custom_loading_widget.dart';

class AddMoneyScreen extends GetView<AddMoneyController> {
  const AddMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ResponsiveLayout(
          mobileScaffold: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: TitleHeading2Widget(
                  text: Strings.addMoney,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0,
                leading:BackButtonWidget(
                  onTap: (){
                    Get.offAllNamed(Routes.dashboardScreen);
                  },
                ),

                iconTheme: IconThemeData(
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              body: Obx(() => controller.isLoading
                  ? const CustomLoadingWidget()
                  : Column(
                      children: [
                        _walletWidget(context),
                        _keyboardAddMoneyWidget(context),
                      ],
                    ))),
        ),
      ),
    );
  }

  _walletWidget(BuildContext context) {
    return Expanded(
        flex: 5,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: TextFormField(
                      textAlign: TextAlign.right,
                      style: Get.isDarkMode
                          ? CustomStyle.darkHeading2TextStyle.copyWith(
                              fontSize: Dimensions.headingTextSize3 * 2)
                          : CustomStyle.lightHeading2TextStyle.copyWith(
                              fontSize: Dimensions.headingTextSize3 * 2),
                      readOnly: true,
                      controller: controller.amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      maxLength: 6,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(8),
                      ],
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return null;
                        } else {
                          return Strings.pleaseFillOutTheField;
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "00.00",
                        counterText: "",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.widthSize * 0.7),
                  _currencyDropDownWidget(context),
                ],
              ),
              verticalSpace(Dimensions.marginSizeVertical * 1),
              // _infoTextWidget(context,
              //     name: Strings.exchangeRate,
              //     value:
              //         "1.00 ${controller.selectedCurrency.value} - ${controller.exchangeRate.value.toStringAsFixed(2)} ${controller.selectedMethodCurrencyCode.value}"),
              // verticalSpace(Dimensions.marginSizeVertical * .2),
              _infoTextWidget(context,
                  name: Strings.charge,
                  value:
                      "${controller.selectedMethodFCharge.value.toStringAsFixed(2)} ${controller.selectedMethodCurrencyCode.value} + ${controller.selectedMethodPCharge.value.toStringAsFixed(2)}%"),
              verticalSpace(Dimensions.marginSizeVertical * .2),
              _infoTextWidget(context,
                  name: Strings.limit,
                  value:
                      "${controller.min.value.toStringAsFixed(controller.selectedCurrencyType.value == "FIAT" ? 2 : 6)} ${controller.selectedCurrency.value} - ${controller.max.value.toStringAsFixed(controller.selectedCurrencyType.value == "FIAT" ? 2 : 6)} ${controller.selectedCurrency.value}"),
              verticalSpace(Dimensions.marginSizeVertical * .5),
            ],
          ),
        ));
  }

  _infoTextWidget(BuildContext context,
      {required String name, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * .5),
      child: Row(
        
        children: [
          TitleHeading5Widget(
            text: name,
            textAlign: TextAlign.center,
            color: Theme.of(context).primaryColor.withOpacity(.8),
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.headingTextSize5 * .89,
          ),
          TitleHeading5Widget(
            text: ": ",
            textAlign: TextAlign.center,
            color: Theme.of(context).primaryColor.withOpacity(.8),
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.headingTextSize5 * .89,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TitleHeading5Widget(
              text: value,
              textAlign: TextAlign.center,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: Dimensions.headingTextSize5 * .85,
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyboardAddMoneyWidget(BuildContext context) {
    return Expanded(
      flex: 12,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.amountController,
        builder: (context, value, _) {
          final amount = double.tryParse(value.text.trim()) ?? 0.0;
          final pct   = controller.selectedMethodPCharge.value;
          final fee   = amount * (pct / 100.0);
          final total = amount + fee;
          final code  = controller.selectedMethodCurrencyCode.value;

          final btnText = 'Top-up';
          return KeyboardScreenWidget(
            onTap: () {
              if (amount > 0) {
                controller.addMoneyBTNClicked(context);
              } else {
                CustomSnackBar.error(Strings.enterAmount);
              }
            },
            buttonText: btnText,
            isLoading: controller.isSubmitLoading,
            amountController: controller.amountController,
          );
        },
      ),
    );
  }



  Widget _currencyDropDownWidget(BuildContext context) {
    return Obx(() {
      final wallets = controller.addMoneyIndexModel.data.userWallet ?? [];

      // 0 items → hide (or show a placeholder; your call)
      if (wallets.isEmpty) {
        return const SizedBox.shrink();
      }

      // 1 item → show read-only chip/field (no dropdown)
      if (wallets.length == 1) {
        final single = wallets.first;

        // Set selection once without causing build-time state churn
        if (controller.selectedCurrency.value != single.title) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.selectedCurrency.value = single.title;
            controller.selectedCurrencyRate.value = single.rate;
            controller.selectedCurrencyImage.value = single.img;
            controller.exchangeCalculation();
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.selectedCurrencyImage.value.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.network(
                    controller.selectedCurrencyImage.value,
                    width: 20,
                    height: 20,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 20, height: 20),
                  ),
                ),
              Text(
                controller.selectedCurrency.value,
                style: TextStyle(
                  color: CustomColor.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }

      // 2+ items → normal dropdown
      return SizedBox(
        child: WalletDropDown<UserWallet>(
          items: wallets,
          image: controller.selectedCurrencyImage.value,
          hint: controller.selectedCurrency.value,
          onChanged: (value) {
            if (value == null) return;
            controller.selectedCurrency.value = value.title;
            controller.selectedCurrencyRate.value = value.rate;
            controller.selectedCurrencyImage.value = value.img;
            controller.exchangeCalculation();
          },
          titleTextColor: CustomColor.whiteColor,
          dropDownColor: Theme.of(context).primaryColor,
          borderEnable: true,
          dropDownFieldColor: Theme.of(context).primaryColor,
          dropDownIconColor: CustomColor.whiteColor,
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
      );
    });
  }


  _paymentMethodDropDownWidget(BuildContext context) {
    return Obx(() => SizedBox(
          // width: Dimensions.widthSize * 20,
          child: WalletDropDown<GatewayCurrency>(
            items: controller.addMoneyIndexModel.data.gatewayCurrencies,
            image: controller.selectedMethodImage.value,
            hint: controller.selectedMethod.value,
            onChanged: (value) {
              controller.selectedMethodID.value = value!.id;
              controller.selectedMethod.value = value.title;
              controller.selectedMethodCurrencyCode.value = value.currencyCode;
              controller.selectedMethodImage.value = value.img;
              controller.selectedMethodType.value = value.type;
              controller.selectedMethodAlias.value = value.alias;
              controller.selectedMethodMax.value = value.max;
              controller.selectedMethodMin.value = value.min;
              controller.selectedMethodPCharge.value = value.pCharge;
              controller.selectedMethodFCharge.value = value.fCharge;
              controller.selectedMethodRate.value = value.rate;

              controller.exchangeCalculation();
            },
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHorizontal * 0.1,
            ),
            titleTextColor: CustomColor.whiteColor,
            dropDownColor: Theme.of(context).primaryColor,
            borderEnable: true,
            dropDownFieldColor: Theme.of(context).primaryColor,
            dropDownIconColor: CustomColor.whiteColor,
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ));
  }
}
