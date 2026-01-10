import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';
import '../../../../shared/presentation/widgets/custom_text_field.dart';
import '../providers/peacelink_provider.dart';

class CreatePeaceLinkScreen extends ConsumerStatefulWidget {
  const CreatePeaceLinkScreen({super.key});

  @override
  ConsumerState<CreatePeaceLinkScreen> createState() => _CreatePeaceLinkScreenState();
}

class _CreatePeaceLinkScreenState extends ConsumerState<CreatePeaceLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Buyer info
  final _buyerMobileController = TextEditingController();
  final _buyerNameController = TextEditingController();

  // Item info
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemPriceController = TextEditingController();

  // Delivery info
  final _deliveryAddressController = TextEditingController();
  final _deliveryFeeController = TextEditingController(text: '50');
  String _deliveryFeePayer = 'buyer';
  
  // Policy settings
  bool _enableAdvancePayment = false;
  double _advancePaymentPercentage = 50;

  // REMOVED: DSP wallet field - should not be set before buyer approves
  // Per bug report: "Merchant Can Add DSP Wallet Before Buyer Approves PoD Request"

  @override
  void dispose() {
    _buyerMobileController.dispose();
    _buyerNameController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemPriceController.dispose();
    _deliveryAddressController.dispose();
    _deliveryFeeController.dispose();
    super.dispose();
  }

  double get _itemPrice => double.tryParse(_itemPriceController.text) ?? 0;
  double get _deliveryFee => double.tryParse(_deliveryFeeController.text) ?? 0;
  double get _advanceAmount => _enableAdvancePayment ? (_itemPrice * _advancePaymentPercentage / 100) : 0;
  double get _total => _itemPrice + _deliveryFee;
  
  // Fee calculations for merchant preview
  double get _merchantFee => (_itemPrice * 0.01) + 3; // 1% + 3 EGP
  double get _merchantNetItem => _itemPrice - _merchantFee;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(peacelinkProvider.notifier).createPeaceLink({
      'buyer_mobile': _buyerMobileController.text,
      'buyer_name': _buyerNameController.text,
      'item_name': _itemNameController.text,
      'item_description': _itemDescriptionController.text,
      'item_price': _itemPrice,
      'delivery_address': _deliveryAddressController.text,
      'delivery_fee': _deliveryFee,
      'delivery_fee_payer': _deliveryFeePayer,
      'advance_payment_enabled': _enableAdvancePayment,
      'advance_payment_percentage': _enableAdvancePayment ? _advancePaymentPercentage : 0,
      // NOTE: DSP wallet is NOT included - will be assigned after buyer approves
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء PeaceLink بنجاح')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنشاء PeaceLink'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء PeaceLink')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 2)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: const Text('التالي'),
                      ),
                    )
                  else
                    Expanded(
                      child: GradientButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        isLoading: _isLoading,
                        child: const Text('إنشاء PeaceLink'),
                      ),
                    ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('رجوع'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Buyer Info
            Step(
              title: const Text('بيانات المشتري'),
              subtitle: const Text('معلومات العميل'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  CustomTextField(
                    controller: _buyerMobileController,
                    label: 'رقم هاتف المشتري',
                    hint: '01xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
                      if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) return 'رقم غير صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _buyerNameController,
                    label: 'اسم المشتري',
                    hint: 'الاسم بالكامل',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'الاسم مطلوب';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Step 2: Item Info
            Step(
              title: const Text('بيانات المنتج'),
              subtitle: const Text('تفاصيل السلعة'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  CustomTextField(
                    controller: _itemNameController,
                    label: 'اسم المنتج',
                    hint: 'مثال: iPhone 15 Pro',
                    prefixIcon: Icons.shopping_bag,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'اسم المنتج مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _itemDescriptionController,
                    label: 'وصف المنتج (اختياري)',
                    hint: 'تفاصيل إضافية',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _itemPriceController,
                    label: 'السعر',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    prefixIcon: Icons.attach_money,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price <= 0) return 'السعر غير صحيح';
                      return null;
                    },
                  ),
                  
                  // Advance Payment Toggle
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('تفعيل الدفع المقدم'),
                    subtitle: const Text('استلام جزء من المبلغ قبل التوصيل'),
                    value: _enableAdvancePayment,
                    onChanged: (value) => setState(() => _enableAdvancePayment = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  if (_enableAdvancePayment) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('نسبة الدفع المقدم: '),
                        Text('${_advancePaymentPercentage.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _advancePaymentPercentage,
                      min: 10,
                      max: 90,
                      divisions: 8,
                      label: '${_advancePaymentPercentage.toInt()}%',
                      onChanged: (value) => setState(() => _advancePaymentPercentage = value),
                    ),
                  ],
                ],
              ),
            ),

            // Step 3: Delivery Info
            Step(
              title: const Text('بيانات التوصيل'),
              subtitle: const Text('العنوان والرسوم'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  CustomTextField(
                    controller: _deliveryAddressController,
                    label: 'عنوان التوصيل',
                    hint: 'العنوان بالتفصيل',
                    prefixIcon: Icons.location_on,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'العنوان مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _deliveryFeeController,
                    label: 'رسوم التوصيل',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    prefixIcon: Icons.local_shipping,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final fee = double.tryParse(value ?? '');
                      if (fee == null || fee < 0) return 'رسوم التوصيل غير صحيحة';
                      if (fee == 0) return 'رسوم التوصيل لا يمكن أن تكون صفر';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('من يدفع رسوم التوصيل؟', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _OptionCard(
                          label: 'المشتري',
                          isSelected: _deliveryFeePayer == 'buyer',
                          onTap: () => setState(() => _deliveryFeePayer = 'buyer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OptionCard(
                          label: 'التاجر',
                          isSelected: _deliveryFeePayer == 'merchant',
                          onTap: () => setState(() => _deliveryFeePayer = 'merchant'),
                        ),
                      ),
                    ],
                  ),
                  
                  // INFO: DSP will be assigned after buyer approves
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سيتم تعيين مندوب التوصيل بعد موافقة المشتري على الطلب',
                            style: TextStyle(color: AppColors.info, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Summary with separated fees for merchant
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ملخص الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _SummaryRow(label: 'سعر المنتج', value: '${_itemPrice.toStringAsFixed(0)} ج.م'),
                        _SummaryRow(label: 'رسوم التوصيل', value: '${_deliveryFee.toStringAsFixed(0)} ج.م'),
                        if (_enableAdvancePayment)
                          _SummaryRow(
                            label: 'الدفعة المقدمة (${_advancePaymentPercentage.toInt()}%)',
                            value: '${_advanceAmount.toStringAsFixed(0)} ج.م',
                            valueColor: AppColors.info,
                          ),
                        const Divider(),
                        _SummaryRow(
                          label: 'إجمالي المشتري',
                          value: '${_total.toStringAsFixed(0)} ج.م',
                          isBold: true,
                        ),
                        const Divider(),
                        // Show merchant fees separately
                        _SummaryRow(
                          label: 'رسوم المنصة (1% + 3)',
                          value: '-${_merchantFee.toStringAsFixed(1)} ج.م',
                          valueColor: AppColors.error,
                        ),
                        _SummaryRow(
                          label: 'صافي المنتج لك',
                          value: '${_merchantNetItem.toStringAsFixed(1)} ج.م',
                          isBold: true,
                          valueColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({required this.label, required this.value, this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: valueColor ?? (isBold ? AppColors.primary : null))),
        ],
      ),
    );
  }
}
