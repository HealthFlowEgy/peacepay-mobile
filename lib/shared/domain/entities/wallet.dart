import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double totalCashout;
  final String currency;
  
  const Wallet({
    this.availableBalance = 0,
    this.pendingBalance = 0,
    this.totalEarnings = 0,
    this.totalCashout = 0,
    this.currency = 'EGP',
  });
  
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      availableBalance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      pendingBalance: double.tryParse(json['pending_balance']?.toString() ?? '0') ?? 0,
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0,
      totalCashout: double.tryParse(json['total_cashout']?.toString() ?? '0') ?? 0,
      currency: json['currency'] ?? 'EGP',
    );
  }
  
  @override
  List<Object?> get props => [availableBalance, pendingBalance, totalEarnings, totalCashout, currency];
}
