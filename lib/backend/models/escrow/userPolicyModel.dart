import '../../../widgets/custom_dropdown_widget/custom_dropdown_widget.dart';

class UserPolicy {
  final bool? success;
  final String? message;
  final PolicyPaginationData? data;
  final String? timestamp;
  final int? statusCode;

  UserPolicy({
    this.success,
    this.message,
    this.data,
    this.timestamp,
    this.statusCode,
  });

  factory UserPolicy.fromJson(Map<String, dynamic> json) {
    return UserPolicy(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? PolicyPaginationData.fromJson(json['data'])
          : null,
      timestamp: json['timestamp'],
      statusCode: json['status_code'],
    );
  }
}

class PolicyPaginationData {
  final int? currentPage;
  final List<PolicyData>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<dynamic>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  PolicyPaginationData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory PolicyPaginationData.fromJson(Map<String, dynamic> json) {
    return PolicyPaginationData(
      currentPage: json['current_page'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PolicyData.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: json['links'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class PolicyData extends DropdownModel {
  final int mId;
  final String? name;
  final String? description;
  final Fields? fields;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;

  PolicyData({
    required this.mId,
    this.name,
    this.description,
    this.fields,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      mId: json['id'],
      name: json['name'],
      description: json['description'],
      fields: json['fields'] != null ? Fields.fromJson(json['fields']) : null,
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': mId,
      'name': name,
      'description': description,
      'fields': fields?.toJson(),
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String get title => name ?? 'Unnamed Policy';

  @override
  int get modelId => mId;

  @override String get currencyCode => '';
  @override String get currencySymbol => '';
  @override double get fCharge => 0.0;
  @override String get img => '';
  @override double get max => 0.0;
  @override String get mcode => '';
  @override double get min => 0.0;
  @override double get pCharge => 0.0;
  @override double get rate => 0.0;
  @override String get type => '';
  @override String get id => mId.toString();
}

class Fields {
  final String? deliveryFeePayer;
  final String? hasAdvancedPayment;

  Fields({this.deliveryFeePayer, this.hasAdvancedPayment});

  factory Fields.fromJson(Map<String, dynamic> json) {
    return Fields(
      deliveryFeePayer: json['delivery_fee_payer'],
      hasAdvancedPayment: json['has_advanced_payment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_fee_payer': deliveryFeePayer,
      'has_advanced_payment': hasAdvancedPayment,
    };
  }
}
