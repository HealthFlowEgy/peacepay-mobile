import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final double balance;
  final double pendingBalance;
  final String currency;
  final double dailyLimit;
  final double monthlyLimit;
  final double? usedDailyLimit;
  final double? usedMonthlyLimit;

  const Wallet({
    required this.id,
    required this.balance,
    this.pendingBalance = 0,
    this.currency = 'EGP',
    this.dailyLimit = 50000,
    this.monthlyLimit = 100000,
    this.usedDailyLimit,
    this.usedMonthlyLimit,
  });

  Wallet copyWith({
    String? id,
    double? balance,
    double? pendingBalance,
    String? currency,
    double? dailyLimit,
    double? monthlyLimit,
    double? usedDailyLimit,
    double? usedMonthlyLimit,
  }) {
    return Wallet(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      currency: currency ?? this.currency,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      usedDailyLimit: usedDailyLimit ?? this.usedDailyLimit,
      usedMonthlyLimit: usedMonthlyLimit ?? this.usedMonthlyLimit,
    );
  }

  double get totalBalance => balance + pendingBalance;
  double get availableDaily => dailyLimit - (usedDailyLimit ?? 0);
  double get availableMonthly => monthlyLimit - (usedMonthlyLimit ?? 0);

  @override
  List<Object?> get props => [id, balance, pendingBalance];
}

enum TransactionType {
  topup,
  cashout,
  transferIn,
  transferOut,
  peacelinkHold,
  peacelinkRelease,
  peacelinkRefund,
  fee,
  incentive,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final double? fee; // ADDED: Fee field for cash-out transactions
  final TransactionStatus status;
  final String description;
  final String? reference;
  final String? peacelinkId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.fee,
    required this.status,
    required this.description,
    this.reference,
    this.peacelinkId,
    required this.createdAt,
    this.completedAt,
  });

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    double? fee,
    TransactionStatus? status,
    String? description,
    String? reference,
    String? peacelinkId,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      peacelinkId: peacelinkId ?? this.peacelinkId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.topup:
        return 'شحن رصيد';
      case TransactionType.cashout:
        return 'سحب';
      case TransactionType.transferIn:
        return 'تحويل وارد';
      case TransactionType.transferOut:
        return 'تحويل صادر';
      case TransactionType.peacelinkHold:
        return 'حجز PeaceLink';
      case TransactionType.peacelinkRelease:
        return 'تحرير PeaceLink';
      case TransactionType.peacelinkRefund:
        return 'استرداد PeaceLink';
      case TransactionType.fee:
        return 'رسوم';
      case TransactionType.incentive:
        return 'حافز';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'قيد الانتظار';
      case TransactionStatus.completed:
        return 'مكتمل';
      case TransactionStatus.failed:
        return 'فشل';
      case TransactionStatus.cancelled:
        return 'ملغي';
    }
  }

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;

  @override
  List<Object?> get props => [id, type, amount, status, createdAt];
}
