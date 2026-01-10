import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/domain/entities/user.dart';
import '../providers/peacelink_provider.dart';
import '../../domain/entities/peacelink.dart';

class PeaceLinksScreen extends ConsumerStatefulWidget {
  const PeaceLinksScreen({super.key});

  @override
  ConsumerState<PeaceLinksScreen> createState() => _PeaceLinksScreenState();
}

class _PeaceLinksScreenState extends ConsumerState<PeaceLinksScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(peacelinkProvider);
    final currentRole = ref.watch(currentRoleProvider);
    
    final filteredList = state.peacelinks.where((p) {
      if (_filter == 'all') return true;
      if (_filter == 'active') {
        return ![PeaceLinkStatus.completed, PeaceLinkStatus.cancelled].contains(p.status);
      }
      if (_filter == 'completed') return p.status == PeaceLinkStatus.completed;
      return true;
    }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PeaceLinks'),
        actions: [
          if (currentRole == UserRole.merchant)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push(Routes.createPeacelink),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(peacelinkProvider.notifier).loadPeaceLinks(),
        child: Column(
          children: [
            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FilterChip(label: 'الكل', value: 'all', selected: _filter, onTap: (v) => setState(() => _filter = v)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'نشط', value: 'active', selected: _filter, onTap: (v) => setState(() => _filter = v)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'مكتمل', value: 'completed', selected: _filter, onTap: (v) => setState(() => _filter = v)),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? _EmptyState(currentRole: currentRole)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) => _PeaceLinkCard(
                            peacelink: filteredList[index],
                            onTap: () => context.push('/peacelinks/${filteredList[index].id}'),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: currentRole == UserRole.merchant
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.createPeacelink),
              icon: const Icon(Icons.add),
              label: const Text('إنشاء PeaceLink'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final UserRole currentRole;
  const _EmptyState({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'لا توجد PeaceLinks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentRole == UserRole.merchant
                  ? 'أنشئ PeaceLink جديد لبدء تلقي المدفوعات'
                  : 'ستظهر هنا روابط الدفع الخاصة بك',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeaceLinkCard extends StatelessWidget {
  final PeaceLink peacelink;
  final VoidCallback onTap;

  const _PeaceLinkCard({required this.peacelink, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(peacelink.status);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getStatusIcon(peacelink.status), color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peacelink.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '#${peacelink.id}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    peacelink.statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${peacelink.totalAmount.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                Row(
                  children: [
                    const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PeaceLinkStatus status) {
    switch (status) {
      case PeaceLinkStatus.created: return AppColors.warning;
      case PeaceLinkStatus.approved: return AppColors.info;
      case PeaceLinkStatus.dspAssigned: return Colors.purple;
      case PeaceLinkStatus.inTransit: return Colors.orange;
      case PeaceLinkStatus.delivered:
      case PeaceLinkStatus.completed: return AppColors.success;
      case PeaceLinkStatus.cancelled: return AppColors.error;
      case PeaceLinkStatus.disputed: return AppColors.error;
    }
  }

  IconData _getStatusIcon(PeaceLinkStatus status) {
    switch (status) {
      case PeaceLinkStatus.created: return Icons.hourglass_empty;
      case PeaceLinkStatus.approved: return Icons.check_circle;
      case PeaceLinkStatus.dspAssigned: return Icons.local_shipping;
      case PeaceLinkStatus.inTransit: return Icons.local_shipping;
      case PeaceLinkStatus.delivered:
      case PeaceLinkStatus.completed: return Icons.check_circle;
      case PeaceLinkStatus.cancelled: return Icons.cancel;
      case PeaceLinkStatus.disputed: return Icons.warning;
    }
  }
}
