import 'package:equatable/equatable.dart';

enum UserRole { buyer, merchant, dsp }

class User extends Equatable {
  final int id;
  final String name;
  final String mobile;
  final String? email;
  final bool smsVerified;
  final bool emailVerified;
  final bool kycVerified;
  final bool hasPin;
  final String kycLevel;
  final UserRole currentRole;
  final List<UserRole> availableRoles;
  final String? walletNumber;
  final double? transactionLimit;
  final double? transactionUsed;
  
  const User({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.smsVerified = false,
    this.emailVerified = false,
    this.kycVerified = false,
    this.hasPin = false,
    this.kycLevel = 'bronze',
    this.currentRole = UserRole.buyer,
    this.availableRoles = const [UserRole.buyer],
    this.walletNumber,
    this.transactionLimit,
    this.transactionUsed,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: '${json['firstname'] ?? ''} ${json['lastname'] ?? ''}'.trim(),
      mobile: json['mobile'] ?? '',
      email: json['email'],
      smsVerified: json['sms_verified'] == 1,
      emailVerified: json['email_verified'] == 1,
      kycVerified: json['kyc_verified'] == 1,
      hasPin: json['has_pin'] == true,
      kycLevel: json['kyc_level'] ?? 'bronze',
      currentRole: _parseRole(json['current_role']),
      availableRoles: _parseRoles(json['available_roles']),
      walletNumber: json['wallet_number'],
      transactionLimit: (json['transaction_limit'] as num?)?.toDouble(),
      transactionUsed: (json['transaction_used'] as num?)?.toDouble(),
    );
  }
  
  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'merchant': return UserRole.merchant;
      case 'dsp': return UserRole.dsp;
      default: return UserRole.buyer;
    }
  }
  
  static List<UserRole> _parseRoles(dynamic roles) {
    if (roles == null) return [UserRole.buyer];
    if (roles is List) {
      return roles.map((r) => _parseRole(r.toString())).toList();
    }
    return [UserRole.buyer];
  }
  
  User copyWith({
    int? id,
    String? name,
    String? mobile,
    String? email,
    bool? smsVerified,
    bool? emailVerified,
    bool? kycVerified,
    bool? hasPin,
    String? kycLevel,
    UserRole? currentRole,
    List<UserRole>? availableRoles,
    String? walletNumber,
    double? transactionLimit,
    double? transactionUsed,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      smsVerified: smsVerified ?? this.smsVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      kycVerified: kycVerified ?? this.kycVerified,
      hasPin: hasPin ?? this.hasPin,
      kycLevel: kycLevel ?? this.kycLevel,
      currentRole: currentRole ?? this.currentRole,
      availableRoles: availableRoles ?? this.availableRoles,
      walletNumber: walletNumber ?? this.walletNumber,
      transactionLimit: transactionLimit ?? this.transactionLimit,
      transactionUsed: transactionUsed ?? this.transactionUsed,
    );
  }
  
  @override
  List<Object?> get props => [id, name, mobile, email, smsVerified, emailVerified, kycVerified, hasPin, currentRole];
}
