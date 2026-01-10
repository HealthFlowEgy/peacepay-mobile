import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';
import '../providers/wallet_provider.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'fawry';
  bool _isLoading = false;

  final _methods = [
    {'id': 'fawry', 'name': 'فوري', 'icon': Icons.store},
    {'id': 'vodafone_cash', 'name': 'فودافون كاش', 'icon': Icons.phone_android},
    {'id': 'instapay', 'name': 'انستاباي', 'icon': Icons.account_balance},
    {'id': 'card', 'name': 'بطاقة ائتمان', 'icon': Icons.credit_card},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الحد الأدنى 10 ج.م')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final success = await ref.read(walletProvider.notifier).addMoney(amount, _selectedMethod);
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الرصيد بنجاح')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة رصيد')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('المبلغ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'ج.م',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [100, 500, 1000].map((amount) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  onPressed: () => _amountController.text = amount.toString(),
                  child: Text('$amount'),
                ),
              ),
            )).toList(),
          ),
          
          const SizedBox(height: 24),
          
          const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          
          ..._methods.map((method) => _PaymentMethodTile(
            id: method['id'] as String,
            name: method['name'] as String,
            icon: method['icon'] as IconData,
            isSelected: _selectedMethod == method['id'],
            onTap: () => setState(() => _selectedMethod = method['id'] as String),
          )),
          
          const SizedBox(height: 32),
          
          GradientButton(
            onPressed: _isLoading ? null : _submit,
            isLoading: _isLoading,
            child: const Text('إضافة الرصيد'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.id,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
