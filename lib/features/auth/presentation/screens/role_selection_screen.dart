import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;

  void _continue() {
    if (_selectedRole == null) return;
    context.push(Routes.pin, extra: {'isSetup': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('كيف ستستخدم PeacePay؟', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('اختر دورك الرئيسي (يمكنك تغييره لاحقاً)', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              _RoleCard(
                icon: Icons.shopping_bag,
                title: 'مشتري',
                description: 'أشتري منتجات عبر الإنترنت وأريد حماية مشترياتي',
                color: AppColors.buyerColor,
                isSelected: _selectedRole == 'buyer',
                onTap: () => setState(() => _selectedRole = 'buyer'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.store,
                title: 'تاجر',
                description: 'أبيع منتجات وأريد ضمان حقوقي وتسهيل الدفع',
                color: AppColors.merchantColor,
                isSelected: _selectedRole == 'merchant',
                onTap: () => setState(() => _selectedRole = 'merchant'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.local_shipping,
                title: 'مندوب توصيل',
                description: 'أوصل الطلبات وأريد الحصول على أرباحي بأمان',
                color: AppColors.dspColor,
                isSelected: _selectedRole == 'dsp',
                onTap: () => setState(() => _selectedRole = 'dsp'),
              ),
              const Spacer(),
              GradientButton(
                onPressed: _selectedRole != null ? _continue : null,
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
