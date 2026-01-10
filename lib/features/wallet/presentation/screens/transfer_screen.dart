import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';
import '../../../../shared/presentation/widgets/custom_text_field.dart';
import '../providers/wallet_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    setState(() => _isLoading = true);
    
    final success = await ref.read(walletProvider.notifier).transfer(
      _recipientController.text,
      amount,
      _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التحويل بنجاح')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل التحويل'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('تحويل')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الرصيد المتاح'),
                  Text(
                    '${walletBalance.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            CustomTextField(
              controller: _recipientController,
              label: 'رقم المحفظة',
              hint: 'PP...',
              textDirection: TextDirection.ltr,
              prefixIcon: Icons.account_balance_wallet,
              validator: (value) {
                if (value == null || value.isEmpty) return 'رقم المحفظة مطلوب';
                if (!value.startsWith('PP')) return 'رقم المحفظة غير صحيح';
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _amountController,
              label: 'المبلغ',
              hint: '0',
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              prefixIcon: Icons.attach_money,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) return 'المبلغ غير صحيح';
                if (amount > walletBalance) return 'الرصيد غير كافي';
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _noteController,
              label: 'ملاحظة (اختياري)',
              hint: 'أضف ملاحظة',
              maxLines: 2,
            ),
            
            const SizedBox(height: 32),
            
            GradientButton(
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
              child: const Text('تحويل'),
            ),
          ],
        ),
      ),
    );
  }
}
