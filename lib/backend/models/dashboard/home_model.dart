

import 'data_of_transaction.dart';

class HomeModel {
  final HomeData data;
  HomeModel({required this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    data: HomeData.fromJson(json['data'] ?? const {}),
  );
}

class HomeData {
  final int totalEscrow;
  final int userId;
  final int completedEscrow;
  final int pendingEscrow;
  final int disputeEscrow;
  final List<UserWallet> userWallet;
  final List<DataOfTransaction> transactions;

  HomeData({
    required this.totalEscrow,
    required this.userId,
    required this.completedEscrow,
    required this.pendingEscrow,
    required this.disputeEscrow,
    required this.userWallet,
    required this.transactions,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    totalEscrow: (json['total_escrow'] ?? 0) as int,
    userId: (json['user_id'] ?? 0) as int,
    completedEscrow: (json['compledted_escrow'] ?? json['completed_escrow'] ?? 0) as int,
    pendingEscrow: (json['pending_escrow'] ?? 0) as int,
    disputeEscrow: (json['dispute_escrow'] ?? 0) as int,
    userWallet: (json['userWallet'] as List? ?? [])
        .map((x) => UserWallet.fromJson(x as Map<String, dynamic>))
        .toList(),
    transactions: (json['transactions'] as List? ?? [])
        .map((x) => DataOfTransaction.fromJson(x as Map<String, dynamic>))
        .toList(),
  );
}

class UserWallet {
  final String name;
  final double balance;
  final String currencyCode;
  final String currencySymbol;
  final String currencyType;
  final double rate;
  final String flag;
  final String imagePath;

  UserWallet({
    required this.name,
    required this.balance,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyType,
    required this.rate,
    required this.flag,
    required this.imagePath,
  });

  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  factory UserWallet.fromJson(Map<String, dynamic> json) => UserWallet(
    name: (json['name'] ?? '') as String,
    balance: _toDouble(json['balance']),
    currencyCode: (json['currency_code'] ?? '') as String,
    currencySymbol: (json['currency_symbol'] ?? '') as String,
    currencyType: (json['currency_type'] ?? '') as String,
    rate: _toDouble(json['rate']),
    flag: (json['flag'] ?? '') as String,
    imagePath: (json['image_path'] ?? '') as String,
  );
}
