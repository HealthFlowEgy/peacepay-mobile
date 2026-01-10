import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/wallet.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';

class WalletState {
  final Wallet? wallet;
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;
  
  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });
  
  WalletState copyWith({
    Wallet? wallet,
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;
  
  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
  });
  
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final ApiClient _apiClient;
  
  WalletNotifier(this._apiClient) : super(const WalletState()) {
    loadWallet();
  }
  
  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiConfig.dashboard);
      final data = response.data['data'];
      
      final wallet = Wallet.fromJson(data['wallet'] ?? {});
      
      state = state.copyWith(wallet: wallet, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> loadTransactions() async {
    try {
      final response = await _apiClient.get(ApiConfig.transactions);
      final data = response.data['data']['transactions'] as List? ?? [];
      
      final transactions = data.map((t) => Transaction.fromJson(t)).toList();
      state = state.copyWith(transactions: transactions);
    } catch (e) {
      // Handle error
    }
  }
  
  Future<bool> addMoney(double amount, String method) async {
    try {
      await _apiClient.post(ApiConfig.addMoney, data: {
        'amount': amount.toString(),
        'payment_gateway': method,
      });
      await loadWallet();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> transfer(String recipient, double amount, String? note) async {
    try {
      await _apiClient.post(ApiConfig.transfer, data: {
        'wallet_number': recipient,
        'amount': amount.toString(),
        'note': note,
      });
      await loadWallet();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> cashout(double amount, String method, Map<String, String> details) async {
    try {
      await _apiClient.post(ApiConfig.moneyOut, data: {
        'amount': amount.toString(),
        'payment_gateway': method,
        ...details,
      });
      await loadWallet();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletNotifier(apiClient);
});

final walletBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletProvider).wallet?.availableBalance ?? 0;
});
