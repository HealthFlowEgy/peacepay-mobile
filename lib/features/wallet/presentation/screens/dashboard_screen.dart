import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../../../../shared/domain/entities/user.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final walletState = ref.watch(walletProvider);
    final currentRole = ref.watch(currentRoleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PeacePay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(Routes.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletProvider.notifier).loadWallet();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، ${user?.name ?? ""}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    _RoleBadge(role: currentRole),
                  ],
                ),
                const Spacer(),
                _RoleSwitcher(currentRole: currentRole, availableRoles: user?.availableRoles ?? []),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الرصيد المتاح',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user?.walletNumber ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${walletState.wallet?.availableBalance.toStringAsFixed(2) ?? "0.00"} ج.م',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _WalletStatItem(
                        label: 'معلق',
                        value: '${walletState.wallet?.pendingBalance.toStringAsFixed(0) ?? "0"} ج.م',
                      ),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _WalletStatItem(
                        label: 'إجمالي الأرباح',
                        value: '${walletState.wallet?.totalEarnings.toStringAsFixed(0) ?? "0"} ج.م',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'إضافة رصيد',
                    color: AppColors.success,
                    onTap: () => context.push(Routes.addMoney),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.send,
                    label: 'تحويل',
                    color: AppColors.info,
                    onTap: () => context.push(Routes.transfer),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.arrow_downward,
                    label: 'سحب',
                    color: AppColors.warning,
                    onTap: () => context.push(Routes.cashout),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Create PeaceLink Card
            if (currentRole == UserRole.merchant) ...[
              InkWell(
                onTap: () => context.push(Routes.createPeacelink),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.merchantColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add_link, color: AppColors.merchantColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إنشاء PeaceLink جديد',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'أرسل رابط دفع آمن لعملائك',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
            
            // DSP Dashboard Link
            if (currentRole == UserRole.dsp) ...[
              InkWell(
                onTap: () => context.push(Routes.dspDeliveries),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.dspColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.local_shipping, color: AppColors.dspColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التوصيلات',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'إدارة التوصيلات المعينة لك',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Recent Activity Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'النشاط الأخير',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push(Routes.wallet),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Recent Transactions
            if (walletState.transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text(
                      'لا توجد معاملات بعد',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...walletState.transactions.take(5).map((t) => _TransactionItem(transaction: t)),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final config = {
      UserRole.buyer: ('مشتري', AppColors.buyerColor),
      UserRole.merchant: ('تاجر', AppColors.merchantColor),
      UserRole.dsp: ('مندوب توصيل', AppColors.dspColor),
    }[role]!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.$2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.$1,
        style: TextStyle(color: config.$2, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RoleSwitcher extends ConsumerWidget {
  final UserRole currentRole;
  final List<UserRole> availableRoles;
  
  const _RoleSwitcher({required this.currentRole, required this.availableRoles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (availableRoles.length <= 1) return const SizedBox();
    
    return PopupMenuButton<UserRole>(
      icon: const Icon(Icons.swap_horiz),
      onSelected: (role) {
        ref.read(authStateProvider.notifier).switchRole(role);
      },
      itemBuilder: (context) => availableRoles
          .where((r) => r != currentRole)
          .map((role) => PopupMenuItem(
                value: role,
                child: Text(_roleLabel(role)),
              ))
          .toList(),
    );
  }
  
  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.buyer: return 'التبديل إلى مشتري';
      case UserRole.merchant: return 'التبديل إلى تاجر';
      case UserRole.dsp: return 'التبديل إلى مندوب';
    }
  }
}

class _WalletStatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _WalletStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

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
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  
  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'credit' || transaction.type == 'add_money';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ج.م',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
