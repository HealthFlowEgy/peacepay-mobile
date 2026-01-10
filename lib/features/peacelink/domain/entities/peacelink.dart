import 'package:equatable/equatable.dart';

enum PeaceLinkStatus {
  created,
  approved,
  dspAssigned,
  inTransit,
  delivered,
  completed,
  cancelled,
  disputed,
}

class PeaceLink extends Equatable {
  final String id;
  final String itemName;
  final String? itemDescription;
  final double itemPrice;
  final double deliveryFee;
  final double totalAmount;
  final PeaceLinkStatus status;
  final String? otp;
  final bool? otpVisible; // BUG-003: Backend controls OTP visibility
  final String? deliveryAddress;
  final DateTime? deliveryDeadline;
  final String? trackingCode;
  final String? buyerName;
  final String? buyerMobile;
  final String? merchantName;
  final String? merchantMobile;
  final String? dspName;
  final String? dspMobile;
  final String? policyName;
  final double? advancedPaymentPercentage; // GAP-2.1: Advanced payment split
  final double? platformFee; // Only visible to merchant
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PeaceLink({
    required this.id,
    required this.itemName,
    this.itemDescription,
    required this.itemPrice,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    this.otp,
    this.otpVisible,
    this.deliveryAddress,
    this.deliveryDeadline,
    this.trackingCode,
    this.buyerName,
    this.buyerMobile,
    this.merchantName,
    this.merchantMobile,
    this.dspName,
    this.dspMobile,
    this.policyName,
    this.advancedPaymentPercentage,
    this.platformFee,
    required this.createdAt,
    this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case PeaceLinkStatus.created:
        return 'في انتظار الموافقة';
      case PeaceLinkStatus.approved:
        return 'تم الموافقة';
      case PeaceLinkStatus.dspAssigned:
        return 'تم تعيين المندوب';
      case PeaceLinkStatus.inTransit:
        return 'جاري التوصيل';
      case PeaceLinkStatus.delivered:
        return 'تم التوصيل';
      case PeaceLinkStatus.completed:
        return 'مكتمل';
      case PeaceLinkStatus.cancelled:
        return 'ملغي';
      case PeaceLinkStatus.disputed:
        return 'في نزاع';
    }
  }

  factory PeaceLink.fromJson(Map<String, dynamic> json) {
    return PeaceLink(
      id: json['id'] ?? json['uuid'] ?? '',
      itemName: json['item_name'] ?? json['itemName'] ?? '',
      itemDescription: json['item_description'] ?? json['itemDescription'],
      itemPrice: (json['item_price'] ?? json['itemPrice'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? json['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? json['totalAmount'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      otp: json['otp']?['code'] ?? json['otp'],
      otpVisible: json['otp']?['visible'] ?? json['otp_visible'], // BUG-003
      deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'],
      deliveryDeadline: json['delivery_deadline'] != null
          ? DateTime.parse(json['delivery_deadline'])
          : null,
      trackingCode: json['tracking_code'] ?? json['trackingCode'],
      buyerName: json['buyer']?['name'] ?? json['buyer_name'],
      buyerMobile: json['buyer']?['mobile'] ?? json['buyer_mobile'],
      merchantName: json['merchant']?['name'] ?? json['merchant_name'],
      merchantMobile: json['merchant']?['mobile'] ?? json['merchant_mobile'],
      dspName: json['dsp']?['name'] ?? json['dsp_name'],
      dspMobile: json['dsp']?['mobile'] ?? json['dsp_mobile'],
      policyName: json['policy']?['name'] ?? json['policy_name'],
      advancedPaymentPercentage: (json['advanced_payment_percentage'] ?? json['advancedPaymentPercentage'])?.toDouble(),
      platformFee: (json['platform_fee'] ?? json['platformFee'])?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  static PeaceLinkStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'created':
        return PeaceLinkStatus.created;
      case 'approved':
        return PeaceLinkStatus.approved;
      case 'dsp_assigned':
      case 'dspassigned':
        return PeaceLinkStatus.dspAssigned;
      case 'in_transit':
      case 'intransit':
        return PeaceLinkStatus.inTransit;
      case 'delivered':
        return PeaceLinkStatus.delivered;
      case 'completed':
        return PeaceLinkStatus.completed;
      case 'cancelled':
        return PeaceLinkStatus.cancelled;
      case 'disputed':
        return PeaceLinkStatus.disputed;
      default:
        return PeaceLinkStatus.created;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'item_description': itemDescription,
      'item_price': itemPrice,
      'delivery_fee': deliveryFee,
      'total_amount': totalAmount,
      'status': status.name,
      'otp': otp != null ? {'code': otp, 'visible': otpVisible} : null,
      'delivery_address': deliveryAddress,
      'delivery_deadline': deliveryDeadline?.toIso8601String(),
      'tracking_code': trackingCode,
      'buyer_name': buyerName,
      'buyer_mobile': buyerMobile,
      'merchant_name': merchantName,
      'merchant_mobile': merchantMobile,
      'dsp_name': dspName,
      'dsp_mobile': dspMobile,
      'policy_name': policyName,
      'advanced_payment_percentage': advancedPaymentPercentage,
      'platform_fee': platformFee,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, status, updatedAt];
}
