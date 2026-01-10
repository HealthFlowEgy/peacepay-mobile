import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class DspDeliveriesScreen extends ConsumerStatefulWidget {
  const DspDeliveriesScreen({super.key});

  @override
  ConsumerState<DspDeliveriesScreen> createState() => _DspDeliveriesScreenState();
}

class _DspDeliveriesScreenState extends ConsumerState<DspDeliveriesScreen> {
  String _filter = 'pending';

  // Mock data
  final _deliveries = [
    {
      'id': 'DEL001',
      'peacelink_id': 'PL123456',
      'item_name': 'iPhone 15 Pro Max',
      'status': 'assigned',
      'pickup_address': 'متجر التقنية، الدقي',
      'delivery_address': '15 شارع التحرير، الجيزة',
      'amount': 45000.0,
      'delivery_fee': 100.0,
    },
    {
      'id': 'DEL002',
      'peacelink_id': 'PL123457',
      'item_name': 'Samsung TV 55"',
      'status': 'picked_up',
      'pickup_address': 'سامسونج شوب، مدينة نصر',
      'delivery_address': '22 شارع مكرم عبيد، نصر',
      'amount': 15000.0,
      'delivery_fee': 150.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDeliveries = _deliveries.where((d) {
      if (_filter == 'pending') return d['status'] == 'assigned' || d['status'] == 'picked_up';
      return d['status'] == 'delivered';
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('التوصيلات')),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _FilterTab(
                    label: 'قيد التوصيل',
                    isSelected: _filter == 'pending',
                    onTap: () => setState(() => _filter = 'pending'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterTab(
                    label: 'مكتمل',
                    isSelected: _filter == 'completed',
                    onTap: () => setState(() => _filter = 'completed'),
                  ),
                ),
              ],
            ),
          ),

          // Deliveries List
          Expanded(
            child: filteredDeliveries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('لا توجد توصيلات', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = filteredDeliveries[index];
                      return _DeliveryCard(
                        delivery: delivery,
                        onTap: () => context.push('/dsp/deliveries/${delivery['id']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dspColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;
  final VoidCallback onTap;

  const _DeliveryCard({required this.delivery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = delivery['status'] as String;
    final statusLabel = status == 'assigned' ? 'في انتظار الاستلام' : 'تم الاستلام - جاري التوصيل';
    final statusColor = status == 'assigned' ? AppColors.warning : AppColors.info;

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
                  child: Icon(
                    status == 'assigned' ? Icons.inventory : Icons.local_shipping,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivery['item_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('#${delivery['peacelink_id']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AddressRow(icon: Icons.store, label: 'الاستلام', address: delivery['pickup_address'] as String),
            const SizedBox(height: 8),
            _AddressRow(icon: Icons.location_on, label: 'التوصيل', address: delivery['delivery_address'] as String),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رسوم التوصيل: ${(delivery['delivery_fee'] as double).toStringAsFixed(0)} ج.م',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String address;

  const _AddressRow({required this.icon, required this.label, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(child: Text(address, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
