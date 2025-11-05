import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';
import 'package:peacepay/widgets/text_labels/title_heading5_widget.dart';
import 'package:flutter/services.dart';
import '../../../../backend/backend_utils/custom_snackbar.dart';
import '../../../../backend/models/money_out/money_out_index_model.dart';
import '../../../../controller/dashboard/my_wallets/money_out_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../widgets/appbar/back_button.dart';
import '../../../../widgets/custom_dropdown_widget/wallet_dropdown_widget.dart';
import '../../../../widgets/keyboard/keyboard_widget.dart';


class MoneyOutScreen extends GetView<MoneyOutController> {
  const MoneyOutScreen({super.key});

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
                text: Strings.moneyOut,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              leading: BackButtonWidget(
                onTap: () => Get.offAllNamed(Routes.dashboardScreen),
              ),
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
            body: Obx(
                  () => controller.isLoading
                  ? const CustomLoadingWidget()
                  : Column(
                children: [
                  _walletWidget(context),
                  _paymentMethodDropDownWidget(context),
                  _keyboardMoneyOutWidget(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WALLET AMOUNT + INFO
  // - Read-only amount field bound to amountController (numeric keypad writes it)
  // - Charge and Limit rows reflect currently selected method (or zeros if none)
  // ---------------------------------------------------------------------------
  Widget _walletWidget(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Obx(
            () => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: TextFormField(
                      textAlign: TextAlign.right,
                      style: Get.isDarkMode
                          ? CustomStyle.darkHeading2TextStyle.copyWith(
                        fontSize: Dimensions.headingTextSize3 * 2,
                      )
                          : CustomStyle.lightHeading2TextStyle.copyWith(
                        fontSize: Dimensions.headingTextSize3 * 2,
                      ),
                      readOnly: true,
                      controller: controller.amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      // NOTE: Max length & input formatters protect UI from overflow.
                      // If you need larger amounts, adjust both (and business rules).
                      maxLength: 6,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(8),
                      ],
                      decoration: const InputDecoration(
                        hintText: "00.00",
                        counterText: "",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.widthSize * 6),
                ],
              ),
            ),
            verticalSpace(Dimensions.marginSizeVertical * 1),
            _infoTextWidget(
              context,
              name: Strings.charge,
              value:
              "${controller.selectedMethodFCharge.value.toStringAsFixed(2)} ${controller.selectedMethodCurrencyCode.value} + ${controller.selectedMethodPCharge.value.toStringAsFixed(2)}%",
            ),
            verticalSpace(Dimensions.marginSizeVertical * .2),
            _infoTextWidget(
              context,
              name: Strings.limit,
              value:
              "${controller.min.value.toStringAsFixed(controller.selectedCurrencyType.value == 'FIAT' ? 2 : 6)} ${controller.selectedCurrency.value} - ${controller.max.value.toStringAsFixed(controller.selectedCurrencyType.value == 'FIAT' ? 2 : 6)} ${controller.selectedCurrency.value}",
            ),
            verticalSpace(Dimensions.marginSizeVertical * .5),
          ],
        ),
      ),
    );
  }

  Widget _infoTextWidget(
      BuildContext context, {
        required String name,
        required String value,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * .5,
      ),
      child: Row(
        children: [
          TitleHeading5Widget(
            text: name,
            color: Theme.of(context).primaryColor.withOpacity(.8),
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.headingTextSize5 * .89,
          ),
          const Text(": "),
          TitleHeading5Widget(
            text: value,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: Dimensions.headingTextSize5 * .85,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NUMERIC KEYBOARD + SUBMIT
  // - Guards checkout: requires amount > 0 AND a selected method (ID != 0)
  // - If KeyboardScreenWidget supports disabled state, you can wire canSubmit.
  // ---------------------------------------------------------------------------
  Widget _keyboardMoneyOutWidget(BuildContext context) {
    return Expanded(
      flex: 12,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.amountController,
        builder: (context, value, _) {
          final amount = double.tryParse(value.text.trim()) ?? 0.0;
          final hasMethod = controller.selectedMethodID.value != 0;
          // final canSubmit = amount > 0 && hasMethod; // use if your button supports disabled

          return KeyboardScreenWidget(
            onTap: () {
              if (amount <= 0) {
                CustomSnackBar.error("Please enter a valid amount");
              } else if (!hasMethod) {
                CustomSnackBar.error("Please select a cash out method first");
              } else {
                controller.moneyOutBTNClicked(context);
              }
            },
            buttonText: Strings.moneyOut,
            isLoading: controller.isSubmitLoading,
            amountController: controller.amountController,
            // enabled: canSubmit, // <— if supported by your KeyboardScreenWidget
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT METHOD DROPDOWN
  // - Uses DropdownButtonFormField to ensure `value: null + hint:` works.
  // - No auto-selection: when selectedMethodID == 0, `value` is null → shows hint.
  // - On selection, we update all dependent observable fields and recalc rates.
  //
  // If you must keep your custom WalletDropDown:
  //   1) Add a `value` parameter of type T? that may be null.
  //   2) When `value == null`, render the `hint` instead of a selected item.
  //   3) Bind it exactly as below (value: selectedOrNull).
  // ---------------------------------------------------------------------------
  Widget _paymentMethodDropDownWidget(BuildContext context) {
    return Obx(() {
      final List<GatewayCurrency> methods =
          controller.moneyOutIndexModel.data.gatewayCurrencies ?? <GatewayCurrency>[];

      // Resolve current selection (or null if none) to keep hint visible initially.
      final GatewayCurrency? selectedOrNull =
      controller.selectedMethodID.value == 0
          ? null
          : methods.firstWhereOrNull(
            (m) => m.id == controller.selectedMethodID.value,
      );

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * 0.5,
          vertical: Dimensions.paddingSizeVertical * 0.25,
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'cash-out method Method',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHorizontal * 0.75,
              vertical: Dimensions.paddingSizeVertical * 0.5,
            ),
          ),
          child: DropdownButtonFormField<GatewayCurrency>(
            isExpanded: true,
            value: selectedOrNull, // ← null initially → shows hint
            hint: const Text('Select your cash-out method'),
            iconEnabledColor: Theme.of(context).primaryColor,
            decoration: const InputDecoration.collapsed(hintText: ''),
            items: methods.map((m) {
              return DropdownMenuItem<GatewayCurrency>(
                value: m,
                child: Row(
                  children: [
                    if ((m.img ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          m.img!,
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        m.title ?? 'Unknown',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              // Guard against null (keeps hint visible)
              if (val == null) return;

              // Update reactive state
              controller.selectedMethodID.value = val.id ;
              controller.selectedMethod.value = val.title ?? '';
              controller.selectedMethodCurrencyCode.value =
                  val.currencyCode ?? '';
              controller.selectedMethodImage.value = val.img ?? '';
              controller.selectedMethodType.value = val.type ?? '';
              controller.selectedMethodAlias.value = val.alias ?? '';
              controller.selectedMethodMax.value = val.max?.toDouble() ?? 0.0;
              controller.selectedMethodMin.value = val.min?.toDouble() ?? 0.0;
              controller.selectedMethodPCharge.value =
                  val.pCharge?.toDouble() ?? 0.0;
              controller.selectedMethodFCharge.value =
                  val.fCharge?.toDouble() ?? 0.0;
              controller.selectedMethodRate.value =
                  val.rate?.toDouble() ?? 0.0;

              // Trigger downstream calculations (FX, fees, etc.)
              controller.exchangeCalculation();
            },
          ),
        ),
      );
    });
  }
}

/* ============================================================================
   DEV NOTES (read by maintainers)
   ----------------------------------------------------------------------------
   1) Default state (no auto-selection)
      - In MoneyOutController.onInit() ensure:
          selectedMethodID.value = 0;
          selectedMethod.value   = '';
        This guarantees `value == null` in the dropdown → we show the hint.

   2) Guard rails on checkout
      - We block checkout in onTap() unless:
          amount > 0 && selectedMethodID.value != 0

   3) Why DropdownButtonFormField?
      - It natively supports `value: null` + `hint:` without hacks.
      - If you keep WalletDropDown, add a nullable `value` param and render hint
        when `value == null`. Bind like:
          value: selectedOrNull
          hint: Text('Select your payment method')

   4) UI/UX consistency
      - InputDecorator provides label + border consistent with form fields.
      - If you have a design system, wire its tokens here (spacing, radius, etc.).

   5) Amount input
      - amountController is read-only here and driven by numeric keypad widget.
        If business requires larger amounts, adjust maxLength/formatters + server rules.

   6) Resilience
      - All GatewayCurrency fields are null-safe.
      - Image.network has an errorBuilder to avoid layout jumps on 404s.

   7) Optional: disable button
      - If KeyboardScreenWidget supports an `enabled` prop, compute:
          final canSubmit = amount > 0 && controller.selectedMethodID.value != 0;
        and pass it through to prevent taps entirely.
   ========================================================================== */
