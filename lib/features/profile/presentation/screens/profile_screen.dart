import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentRole = user?.currentRole ?? 'buyer';
    final availableRoles = user?.availableRoles ?? ['buyer'];

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'المستخدم',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.mobile ?? '',
                        style: const TextStyle(color: Colors.white70),
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getKycLevelLabel(user?.kycLevel ?? 'bronze'),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRoleColor(currentRole).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getRoleLabel(currentRole),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CRITICAL: Multi-Role Switching Section (REQ-001)
          if (availableRoles.length > 1) ...[
            const Text('تبديل الدور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'اختر الدور الذي تريد استخدامه',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _RoleSwitcher(
              currentRole: currentRole,
              availableRoles: availableRoles,
              onRoleSelected: (role) async {
                final success = await ref.read(authStateProvider.notifier).switchRole(role);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم التبديل إلى ${_getRoleLabel(role)}')),
                  );
                  // Navigate to appropriate dashboard based on role
                  if (role == 'dsp') {
                    context.go(Routes.dspDashboard);
                  } else {
                    context.go(Routes.home);
                  }
                }
              },
            ),
            const Divider(height: 32),
          ],

          // Menu Items
          _MenuItem(icon: Icons.person_outline, title: 'المعلومات الشخصية', onTap: () {}),
          _MenuItem(
            icon: Icons.verified_user_outlined,
            title: 'التحقق من الهوية',
            subtitle: user?.kycVerified == true ? 'موثق ✓' : _getKycLevelLabel(user?.kycLevel ?? 'bronze'),
            onTap: () => context.push(Routes.kyc),
          ),
          
          // Wallet Limit Display
          _MenuItem(
            icon: Icons.account_balance_wallet,
            title: 'حد المحفظة الحالي',
            subtitle: '${_getWalletLimit(user?.kycLevel ?? 'bronze')} ج.م',
            trailing: TextButton(
              onPressed: () => context.push(Routes.kyc),
              child: const Text('ترقية'),
            ),
            onTap: () => context.push(Routes.kyc),
          ),
          
          _MenuItem(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () {}),
          _MenuItem(icon: Icons.pin_outlined, title: 'تغيير رمز PIN', onTap: () {}),

          const Divider(height: 32),

          _MenuItem(icon: Icons.history, title: 'سجل المعاملات', onTap: () => context.push(Routes.wallet)),
          _MenuItem(icon: Icons.report_problem_outlined, title: 'النزاعات', onTap: () => context.push(Routes.disputes)),
          _MenuItem(icon: Icons.notifications_outlined, title: 'الإشعارات', onTap: () => context.push(Routes.notifications)),

          const Divider(height: 32),

          _MenuItem(icon: Icons.help_outline, title: 'المساعدة والدعم', onTap: () {}),
          _MenuItem(icon: Icons.info_outline, title: 'عن التطبيق', onTap: () {}),
          _MenuItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            titleColor: AppColors.error,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('تأكيد', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go(Routes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'buyer': return 'مشتري';
      case 'merchant': return 'تاجر';
      case 'dsp': return 'مندوب';
      default: return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'buyer': return AppColors.buyerColor;
      case 'merchant': return AppColors.merchantColor;
      case 'dsp': return AppColors.dspColor;
      default: return AppColors.primary;
    }
  }

  String _getKycLevelLabel(String level) {
    switch (level) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      default: return level;
    }
  }

  String _getWalletLimit(String level) {
    switch (level) {
      case 'bronze': return '5,000';
      case 'silver': return '50,000';
      case 'gold': return 'غير محدود';
      default: return '5,000';
    }
  }
}

// CRITICAL: Role Switcher Widget (REQ-001)
class _RoleSwitcher extends StatelessWidget {
  final String currentRole;
  final List<String> availableRoles;
  final Function(String) onRoleSelected;

  const _RoleSwitcher({
    required this.currentRole,
    required this.availableRoles,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: availableRoles.map((role) {
        final isSelected = role == currentRole;
        final color = _getRoleColor(role);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: isSelected ? null : () => onRoleSelected(role),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_getRoleIcon(role), color: color, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRoleLabel(role),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('الحالي', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'buyer': return 'مشتري';
      case 'merchant': return 'تاجر';
      case 'dsp': return 'مندوب';
      default: return role;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'buyer': return Icons.shopping_bag;
      case 'merchant': return Icons.store;
      case 'dsp': return Icons.local_shipping;
      default: return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'buyer': return AppColors.buyerColor;
      case 'merchant': return AppColors.merchantColor;
      case 'dsp': return AppColors.dspColor;
      default: return AppColors.primary;
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (titleColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: titleColor ?? AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
                  if (subtitle != null) Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
