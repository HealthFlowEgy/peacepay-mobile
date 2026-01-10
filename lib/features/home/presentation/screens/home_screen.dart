import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مرحباً ${user?.name ?? ""}! 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('ماذا تريد أن تفعل اليوم؟', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  onPressed: () => context.push(Routes.notifications),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Wallet Card
            InkWell(
              onTap: () => context.push(Routes.wallet),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('رصيد المحفظة', style: TextStyle(color: Colors.white70)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.visibility, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('إظهار', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('5,000.00 ج.م', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _QuickAction(icon: Icons.add, label: 'إضافة', onTap: () => context.push(Routes.addMoney)),
                        const SizedBox(width: 16),
                        _QuickAction(icon: Icons.send, label: 'تحويل', onTap: () {}),
                        const SizedBox(width: 16),
                        _QuickAction(icon: Icons.qr_code_scanner, label: 'مسح', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Grid
            const Text('الخدمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _ServiceCard(
                  icon: Icons.link,
                  label: 'PeaceLinks',
                  color: AppColors.primary,
                  onTap: () => context.push(Routes.peacelinks),
                ),
                _ServiceCard(
                  icon: Icons.local_shipping,
                  label: 'التوصيلات',
                  color: AppColors.dspColor,
                  onTap: () => context.push(Routes.dspDashboard),
                ),
                _ServiceCard(
                  icon: Icons.account_balance_wallet,
                  label: 'المحفظة',
                  color: Colors.purple,
                  onTap: () => context.push(Routes.wallet),
                ),
                _ServiceCard(
                  icon: Icons.gavel,
                  label: 'النزاعات',
                  color: AppColors.warning,
                  onTap: () => context.push(Routes.disputes),
                ),
                _ServiceCard(
                  icon: Icons.policy,
                  label: 'السياسات',
                  color: AppColors.info,
                  onTap: () => context.push(Routes.policies),
                ),
                _ServiceCard(
                  icon: Icons.person,
                  label: 'حسابي',
                  color: Colors.teal,
                  onTap: () => context.push(Routes.profile),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('النشاط الأخير', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('عرض الكل')),
              ],
            ),
            _ActivityItem(
              icon: Icons.check_circle,
              iconColor: AppColors.success,
              title: 'تم إكمال PeaceLink',
              subtitle: 'iPhone 15 Pro Max',
              amount: '45,000 ج.م',
              time: 'منذ ساعة',
            ),
            _ActivityItem(
              icon: Icons.local_shipping,
              iconColor: AppColors.info,
              title: 'جاري التوصيل',
              subtitle: 'Samsung TV 55"',
              amount: '15,000 ج.م',
              time: 'منذ 3 ساعات',
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
