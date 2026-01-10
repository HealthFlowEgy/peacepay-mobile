import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';
import '../../../../shared/presentation/widgets/custom_text_field.dart';
import '../providers/wallet_provider.dart';

class CashoutScreen extends ConsumerStatefulWidget {
  const CashoutScreen({super.key});

  @override
  ConsumerState<CashoutScreen> createState() => _CashoutScreenState();
}

class _CashoutScreenState extends ConsumerState<CashoutScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedMethod = 'bank';
  bool _isLoading = false;

  // FEE CONSTANTS - Must match backend
  static const double cashoutFeePercentage = 0.015; // 1.5%
  static const double minCashout = 10.0;
  
  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _fee => _amount * cashoutFeePercentage;
  double get _totalDeduction => _amount + _fee; // FIXED: Total to be deducted from wallet
  double get _netAmount => _amount; // What user receives

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final walletState = ref.read(walletProvider);
    final balance = walletState.wallet?.balance ?? 0;

    // FIXED: Check if wallet has enough for amount + fee
    if (_totalDeduction > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرصيد غير كافٍ. المطلوب: ${_totalDeduction.toStringAsFixed(2)} ج.م (المبلغ + الرسوم)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // FIXED: Deduct amount + fee at request time (not on approval)
    final success = await ref.read(walletProvider.notifier).requestCashout(
      amount: _amount,
      fee: _fee,
      totalDeduction: _totalDeduction,
      method: _selectedMethod,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب السحب بنجاح')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إرسال الطلب'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final balance = walletState.wallet?.balance ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('سحب الرصيد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('الرصيد المتاح', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      '${balance.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Amount Input
              CustomTextField(
                controller: _amountController,
                label: 'المبلغ المراد سحبه',
                hint: '0',
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                prefixIcon: Icons.attach_money,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) return 'أدخل مبلغ صحيح';
                  if (amount < minCashout) return 'الحد الأدنى للسحب $minCashout ج.م';
                  final total = amount + (amount * cashoutFeePercentage);
                  if (total > balance) return 'الرصيد غير كافٍ (المبلغ + الرسوم)';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Quick Amount Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [100, 500, 1000, 2000].map((amount) {
                  final total = amount + (amount * cashoutFeePercentage);
                  final isDisabled = total > balance;
                  return ChoiceChip(
                    label: Text('$amount ج.م'),
                    selected: _amount == amount,
                    onSelected: isDisabled ? null : (selected) {
                      if (selected) {
                        _amountController.text = amount.toString();
                        setState(() {});
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Method Selection
              const Text('طريقة السحب', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MethodCard(
                      icon: Icons.account_balance,
                      label: 'تحويل بنكي',
                      isSelected: _selectedMethod == 'bank',
                      onTap: () => setState(() => _selectedMethod = 'bank'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MethodCard(
                      icon: Icons.phone_android,
                      label: 'محفظة إلكترونية',
                      isSelected: _selectedMethod == 'wallet',
                      onTap: () => setState(() => _selectedMethod = 'wallet'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // FIXED: Fee Summary - Shows that fee is deducted at request time
              if (_amount > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المبلغ المطلوب'),
                          Text('${_amount.toStringAsFixed(2)} ج.م'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('رسوم السحب (1.5%)'),
                          Text('${_fee.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.error)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي الخصم من المحفظة', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${_totalDeduction.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ستحصل على', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${_netAmount.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'سيتم خصم المبلغ والرسوم من محفظتك فور إرسال الطلب',
                                style: TextStyle(fontSize: 12, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              GradientButton(
                onPressed: _isLoading || _amount <= 0 ? null : _submit,
                isLoading: _isLoading,
                child: const Text('إرسال طلب السحب'),
              ),

              const SizedBox(height: 16),

              // Info
              const Text(
                'ملاحظة: يتم معالجة طلبات السحب خلال 1-3 أيام عمل',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
