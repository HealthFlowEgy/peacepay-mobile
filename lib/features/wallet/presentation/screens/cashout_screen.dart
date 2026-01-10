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
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _method = 'bank';
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String _selectedBank = '';
  bool _isLoading = false;

  final _banks = ['البنك الأهلي المصري', 'بنك مصر', 'البنك التجاري الدولي', 'QNB'];

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _fee => _amount * (_method == 'bank' ? 0.015 : 0.01);
  double get _netAmount => _amount - _fee;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await ref.read(walletProvider.notifier).cashout(
      _amount,
      _method,
      {
        'bank': _selectedBank,
        'account_number': _accountNumberController.text,
        'account_name': _accountNameController.text,
      },
    );
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب السحب')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('سحب الرصيد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('الرصيد المتاح للسحب', style: TextStyle(color: Colors.white70)),
                  Text(
                    '${walletBalance.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text('طريقة السحب', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _MethodCard(
                    icon: Icons.account_balance,
                    label: 'تحويل بنكي',
                    isSelected: _method == 'bank',
                    onTap: () => setState(() => _method = 'bank'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodCard(
                    icon: Icons.phone_android,
                    label: 'محفظة إلكترونية',
                    isSelected: _method == 'mobile',
                    onTap: () => setState(() => _method = 'mobile'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            CustomTextField(
              controller: _amountController,
              label: 'المبلغ',
              hint: '0',
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount < 100) return 'الحد الأدنى 100 ج.م';
                if (amount > walletBalance) return 'الرصيد غير كافي';
                return null;
              },
            ),
            
            if (_method == 'bank') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBank.isNotEmpty ? _selectedBank : null,
                decoration: const InputDecoration(labelText: 'البنك'),
                items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (value) => setState(() => _selectedBank = value ?? ''),
                validator: (value) => value == null ? 'اختر البنك' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _accountNumberController,
                label: 'رقم الحساب / IBAN',
                hint: 'EG...',
                textDirection: TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'رقم الحساب مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _accountNameController,
                label: 'اسم صاحب الحساب',
                hint: 'الاسم بالكامل',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'الاسم مطلوب';
                  return null;
                },
              ),
            ],
            
            if (_amount > 0) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SummaryRow(label: 'المبلغ', value: '${_amount.toStringAsFixed(2)} ج.م'),
                    _SummaryRow(
                      label: 'الرسوم (${_method == 'bank' ? '1.5%' : '1%'})',
                      value: '-${_fee.toStringAsFixed(2)} ج.م',
                      valueColor: AppColors.error,
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: 'المبلغ الصافي',
                      value: '${_netAmount.toStringAsFixed(2)} ج.م',
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            GradientButton(
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
              child: const Text('تأكيد السحب'),
            ),
          ],
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
              style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ],
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

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
