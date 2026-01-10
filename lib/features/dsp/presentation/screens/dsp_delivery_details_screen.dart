import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';

class DspDeliveryDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const DspDeliveryDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<DspDeliveryDetailsScreen> createState() => _DspDeliveryDetailsScreenState();
}

class _DspDeliveryDetailsScreenState extends ConsumerState<DspDeliveryDetailsScreen> {
  bool _isLoading = false;
  bool _showOtpDialog = false;
  final _otpController = TextEditingController();

  // Mock delivery data
  final _delivery = {
    'id': 'DEL001',
    'peacelink_id': 'PL123456',
    'status': 'picked_up',
    'item_name': 'iPhone 15 Pro Max',
    'item_description': '256GB، لون أسود، جديد بالكرتونة',
    'item_price': 45000.0,
    'delivery_fee': 100.0,
    'buyer_name': 'أحمد محمد',
    'buyer_mobile': '01012345678',
    'merchant_name': 'متجر التقنية',
    'merchant_mobile': '01098765432',
    'pickup_address': 'متجر التقنية، 5 شارع البطل أحمد عبدالعزيز، الدقي',
    'delivery_address': '15 شارع التحرير، الدقي، الجيزة',
  };

  Future<void> _confirmPickup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _delivery['status'] = 'picked_up';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تأكيد استلام الشحنة')),
      );
    }
  }

  Future<void> _confirmDelivery() async {
    setState(() => _showOtpDialog = true);
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 4) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // In real app, verify OTP with API
    if (_otpController.text == '1234') {
      setState(() {
        _isLoading = false;
        _showOtpDialog = false;
        _delivery['status'] = 'delivered';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تأكيد التوصيل بنجاح! 🎉'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز OTP غير صحيح'), backgroundColor: AppColors.error),
      );
      _otpController.clear();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _delivery['status'] as String;

    return Scaffold(
      appBar: AppBar(title: Text('توصيل #${_delivery['id']}')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getStatusLabel(status), style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                        Text(_getStatusHint(status), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Item Info
              _SectionCard(
                title: 'تفاصيل الشحنة',
                icon: Icons.inventory,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_delivery['item_name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_delivery['item_description'] != null)
                      Text(_delivery['item_description'] as String, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('قيمة الشحنة'),
                        Text('${(_delivery['item_price'] as double).toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('رسوم التوصيل'),
                        Text('${(_delivery['delivery_fee'] as double).toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pickup Address
              _AddressCard(
                title: 'عنوان الاستلام',
                address: _delivery['pickup_address'] as String,
                contactName: _delivery['merchant_name'] as String,
                contactMobile: _delivery['merchant_mobile'] as String,
                icon: Icons.store,
                color: AppColors.merchantColor,
              ),

              const SizedBox(height: 12),

              // Delivery Address
              _AddressCard(
                title: 'عنوان التوصيل',
                address: _delivery['delivery_address'] as String,
                contactName: _delivery['buyer_name'] as String,
                contactMobile: _delivery['buyer_mobile'] as String,
                icon: Icons.location_on,
                color: AppColors.buyerColor,
              ),

              const SizedBox(height: 100), // Space for bottom button
            ],
          ),

          // Bottom Action Button
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
              child: status == 'assigned'
                  ? GradientButton(
                      onPressed: _isLoading ? null : _confirmPickup,
                      isLoading: _isLoading,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, color: Colors.white),
                          SizedBox(width: 8),
                          Text('تأكيد استلام الشحنة'),
                        ],
                      ),
                    )
                  : status == 'picked_up'
                      ? GradientButton(
                          onPressed: _confirmDelivery,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('تأكيد التوصيل (إدخال OTP)'),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('تم التوصيل بنجاح', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
            ),
          ),

          // OTP Dialog
          if (_showOtpDialog)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.dspColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.pin, color: AppColors.dspColor, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text('أدخل رمز OTP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'اطلب رمز التأكيد من العميل للتحقق من التوصيل',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          controller: _otpController,
                          length: 4,
                          defaultPinTheme: PinTheme(
                            width: 56,
                            height: 56,
                            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 56,
                            height: 56,
                            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.dspColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onCompleted: (_) => _verifyOtp(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _showOtpDialog = false);
                                _otpController.clear();
                              },
                              child: const Text('إلغاء'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              onPressed: _isLoading ? null : _verifyOtp,
                              isLoading: _isLoading,
                              child: const Text('تأكيد'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned': return AppColors.warning;
      case 'picked_up': return AppColors.info;
      case 'delivered': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'assigned': return Icons.inventory;
      case 'picked_up': return Icons.local_shipping;
      case 'delivered': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'assigned': return 'في انتظار الاستلام';
      case 'picked_up': return 'جاري التوصيل';
      case 'delivered': return 'تم التوصيل';
      default: return status;
    }
  }

  String _getStatusHint(String status) {
    switch (status) {
      case 'assigned': return 'توجه لاستلام الشحنة من التاجر';
      case 'picked_up': return 'توصيل الشحنة للعميل';
      case 'delivered': return 'تم إكمال التوصيل بنجاح';
      default: return '';
    }
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
              Icon(icon, size: 20, color: AppColors.dspColor),
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

class _AddressCard extends StatelessWidget {
  final String title;
  final String address;
  final String contactName;
  final String contactMobile;
  final IconData icon;
  final Color color;

  const _AddressCard({
    required this.title,
    required this.address,
    required this.contactName,
    required this.contactMobile,
    required this.icon,
    required this.color,
  });

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(address, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(contactName, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              InkWell(
                onTap: () {
                  // Call contact
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      Text(contactMobile, style: const TextStyle(color: AppColors.success, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
