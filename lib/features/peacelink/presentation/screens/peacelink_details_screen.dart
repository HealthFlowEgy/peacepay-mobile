import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/peacelink_provider.dart';
import '../../domain/entities/peacelink.dart';

class PeaceLinkDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const PeaceLinkDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<PeaceLinkDetailsScreen> createState() => _PeaceLinkDetailsScreenState();
}

class _PeaceLinkDetailsScreenState extends ConsumerState<PeaceLinkDetailsScreen> {
  PeaceLink? _peacelink;
  bool _isLoading = true;
  bool _showOtp = false;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = await ref.read(peacelinkProvider.notifier).getPeaceLinkDetails(widget.id);
    setState(() {
      _peacelink = details;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ!')),
    );
  }

  // REQ-002: Handle Cancel Action
  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء PeaceLink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'قد يتم خصم رسوم إلغاء حسب سياسة الطلب',
                      style: TextStyle(color: AppColors.warning, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('رجوع')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إلغاء الطلب', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isActionLoading = true);
      final success = await ref.read(peacelinkProvider.notifier).cancelPeaceLink(widget.id);
      setState(() => _isActionLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الطلب')),
        );
        _loadDetails(); // Refresh
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إلغاء الطلب'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // REQ-002: Handle Open Dispute Action
  Future<void> _handleDispute() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _DisputeDialog(),
    );

    if (reason != null && reason.isNotEmpty) {
      setState(() => _isActionLoading = true);
      // Call dispute API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      setState(() => _isActionLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم فتح النزاع بنجاح')),
        );
        context.push(Routes.disputes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isBuyer = user?.currentRole == 'buyer';
    final isMerchant = user?.currentRole == 'merchant';
    final isDsp = user?.currentRole == 'dsp';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_peacelink == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('لم يتم العثور على PeaceLink')),
      );
    }

    final pl = _peacelink!;
    final statusColor = _getStatusColor(pl.status);

    // BUG-003: OTP Visibility Logic
    // OTP should only be visible to buyer when DSP is assigned AND status is in transit or DSP assigned
    final shouldShowOtp = isBuyer && 
        pl.otp != null && 
        pl.otpVisible == true &&
        [PeaceLinkStatus.dspAssigned, PeaceLinkStatus.inTransit].contains(pl.status);

    // Determine which actions to show based on role and status
    final canCancel = (isBuyer || isMerchant) && 
        [PeaceLinkStatus.created, PeaceLinkStatus.approved].contains(pl.status);
    final canDispute = (isBuyer || isMerchant) && 
        [PeaceLinkStatus.inTransit, PeaceLinkStatus.delivered].contains(pl.status);
    final canApprove = isBuyer && pl.status == PeaceLinkStatus.created;

    return Scaffold(
      appBar: AppBar(
        title: Text('PeaceLink #${pl.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadDetails,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_getStatusIcon(pl.status), color: statusColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pl.itemName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                pl.statusLabel,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BUG-003: OTP Card - Only visible to buyer when conditions are met
                if (shouldShowOtp) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.shield, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('رمز التأكيد (OTP)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(_showOtp ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                              onPressed: () => setState(() => _showOtp = !_showOtp),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showOtp ? pl.otp! : '••••',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                            ),
                            if (_showOtp) ...[
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.white),
                                onPressed: () => _copyToClipboard(pl.otp!),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أعطِ هذا الرمز للمندوب عند استلام الشحنة',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Product Info Card
                _SectionCard(
                  title: 'تفاصيل المنتج',
                  icon: Icons.inventory,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pl.itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (pl.itemDescription != null)
                        Text(pl.itemDescription!, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Amounts Card - Different view for buyer vs merchant
                _SectionCard(
                  title: 'تفاصيل المبالغ',
                  icon: Icons.attach_money,
                  child: Column(
                    children: [
                      _DetailRow(label: 'سعر المنتج', value: '${pl.itemPrice.toStringAsFixed(0)} ج.م'),
                      _DetailRow(label: 'رسوم التوصيل', value: '${pl.deliveryFee.toStringAsFixed(0)} ج.م'),
                      if (pl.advancedPaymentPercentage != null && pl.advancedPaymentPercentage! > 0) ...[
                        _DetailRow(
                          label: 'دفعة مقدمة (${pl.advancedPaymentPercentage!.toInt()}%)',
                          value: '${(pl.itemPrice * pl.advancedPaymentPercentage! / 100).toStringAsFixed(0)} ج.م',
                          valueColor: AppColors.info,
                        ),
                      ],
                      // Only show fees to merchant (not buyer per UI/UX gap)
                      if (isMerchant && pl.platformFee != null) ...[
                        _DetailRow(
                          label: 'رسوم المنصة',
                          value: '${pl.platformFee!.toStringAsFixed(0)} ج.م',
                          valueColor: AppColors.error,
                        ),
                      ],
                      const Divider(),
                      _DetailRow(
                        label: 'الإجمالي',
                        value: '${pl.totalAmount.toStringAsFixed(0)} ج.م',
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Delivery Info
                if (pl.deliveryAddress != null)
                  _SectionCard(
                    title: 'معلومات التوصيل',
                    icon: Icons.location_on,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pl.deliveryAddress!, style: const TextStyle(fontWeight: FontWeight.w500)),
                        if (pl.trackingCode != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'كود التتبع: ${pl.trackingCode}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ],
                        if (pl.deliveryDeadline != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                'الموعد النهائي: ${_formatDate(pl.deliveryDeadline!)}',
                                style: const TextStyle(color: AppColors.warning, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Timeline (REQ-002: State Machine Visualization)
                _SectionCard(
                  title: 'مسار الطلب',
                  icon: Icons.timeline,
                  child: _Timeline(currentStatus: pl.status),
                ),

                const SizedBox(height: 16),

                // Parties Info
                Row(
                  children: [
                    if (pl.merchantName != null)
                      Expanded(
                        child: _PartyCard(
                          title: 'التاجر',
                          name: pl.merchantName!,
                          icon: Icons.store,
                          color: AppColors.merchantColor,
                        ),
                      ),
                    if (pl.merchantName != null && pl.dspName != null)
                      const SizedBox(width: 12),
                    if (pl.dspName != null)
                      Expanded(
                        child: _PartyCard(
                          title: 'المندوب',
                          name: pl.dspName!,
                          icon: Icons.local_shipping,
                          color: AppColors.dspColor,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Action Buttons
          if (canCancel || canDispute || canApprove)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (canApprove) ...[
                      Expanded(
                        child: GradientButton(
                          onPressed: _isActionLoading ? null : () {
                            // Handle approve and pay
                          },
                          child: const Text('الموافقة والدفع'),
                        ),
                      ),
                    ],
                    if (canCancel) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isActionLoading ? null : _handleCancel,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: _isActionLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('إلغاء الطلب', style: TextStyle(color: AppColors.error)),
                        ),
                      ),
                    ],
                    if (canDispute) ...[
                      if (canCancel) const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isActionLoading ? null : _handleDispute,
                          icon: const Icon(Icons.warning_amber, color: AppColors.warning),
                          label: const Text('فتح نزاع', style: TextStyle(color: AppColors.warning)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.warning),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
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
      case PeaceLinkStatus.cancelled:
      case PeaceLinkStatus.disputed: return AppColors.error;
    }
  }

  IconData _getStatusIcon(PeaceLinkStatus status) {
    switch (status) {
      case PeaceLinkStatus.created: return Icons.hourglass_empty;
      case PeaceLinkStatus.approved: return Icons.check_circle;
      case PeaceLinkStatus.dspAssigned:
      case PeaceLinkStatus.inTransit: return Icons.local_shipping;
      case PeaceLinkStatus.delivered:
      case PeaceLinkStatus.completed: return Icons.check_circle;
      case PeaceLinkStatus.cancelled: return Icons.cancel;
      case PeaceLinkStatus.disputed: return Icons.warning;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'م' : 'ص'}';
  }
}

// Timeline Widget for State Machine Visualization (REQ-002)
class _Timeline extends StatelessWidget {
  final PeaceLinkStatus currentStatus;

  const _Timeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('created', 'تم إنشاء الطلب', Icons.add_circle),
      ('approved', 'تم الموافقة والدفع', Icons.payment),
      ('dsp_assigned', 'تم تعيين المندوب', Icons.person_pin),
      ('in_transit', 'جاري التوصيل', Icons.local_shipping),
      ('delivered', 'تم التوصيل', Icons.check_circle),
    ];

    final statusOrder = {
      PeaceLinkStatus.created: 0,
      PeaceLinkStatus.approved: 1,
      PeaceLinkStatus.dspAssigned: 2,
      PeaceLinkStatus.inTransit: 3,
      PeaceLinkStatus.delivered: 4,
      PeaceLinkStatus.completed: 5,
      PeaceLinkStatus.cancelled: -1,
      PeaceLinkStatus.disputed: -1,
    };

    final currentIndex = statusOrder[currentStatus] ?? 0;

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isPending = index > currentIndex;

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? (isCurrent ? AppColors.primary : AppColors.success)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : step.$3,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: isCompleted ? AppColors.success : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  step.$2,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isPending ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// Dispute Dialog
class _DisputeDialog extends StatefulWidget {
  @override
  State<_DisputeDialog> createState() => _DisputeDialogState();
}

class _DisputeDialogState extends State<_DisputeDialog> {
  String? _selectedReason;
  final _detailsController = TextEditingController();

  final _reasons = [
    'المنتج لم يصل',
    'المنتج تالف',
    'المنتج مختلف عن الوصف',
    'مشكلة في التوصيل',
    'أخرى',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('فتح نزاع'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سبب النزاع', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._reasons.map((reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) => setState(() => _selectedReason = value),
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'تفاصيل إضافية (اختياري)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _selectedReason != null
              ? () => Navigator.pop(context, _selectedReason)
              : null,
          child: const Text('فتح النزاع'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
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
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  final String title;
  final String name;
  final IconData icon;
  final Color color;

  const _PartyCard({
    required this.title,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
