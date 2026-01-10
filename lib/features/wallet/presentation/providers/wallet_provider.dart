import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/wallet.dart';

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

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState());

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        wallet: Wallet(
          id: 'W001',
          balance: 5000,
          pendingBalance: 500,
          currency: 'EGP',
          dailyLimit: 50000,
          monthlyLimit: 100000,
        ),
        transactions: [
          Transaction(
            id: 'TXN001',
            type: TransactionType.topup,
            amount: 500,
            status: TransactionStatus.completed,
            description: 'شحن رصيد - فوري',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Transaction(
            id: 'TXN002',
            type: TransactionType.peacelinkHold,
            amount: -1500,
            status: TransactionStatus.pending,
            description: 'PeaceLink - iPhone 15',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addMoney(double amount, String method) async {
    try {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(seconds: 1));
      
      if (state.wallet != null) {
        final newBalance = state.wallet!.balance + amount;
        state = state.copyWith(
          wallet: state.wallet!.copyWith(balance: newBalance),
          isLoading: false,
        );
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // FIXED: Cash-out with fee deducted at request time
  Future<bool> requestCashout({
    required double amount,
    required double fee,
    required double totalDeduction,
    required String method,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Check balance
      if (state.wallet == null || state.wallet!.balance < totalDeduction) {
        state = state.copyWith(isLoading: false, error: 'الرصيد غير كافٍ');
        return false;
      }

      await Future.delayed(const Duration(seconds: 1));
      
      // FIXED: Deduct amount + fee immediately at request time
      final newBalance = state.wallet!.balance - totalDeduction;
      final newPending = state.wallet!.pendingBalance + amount; // Only the amount goes to pending
      
      // Add transaction record
      final newTransaction = Transaction(
        id: 'CSH${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.cashout,
        amount: -totalDeduction, // Total deducted (amount + fee)
        fee: fee,
        status: TransactionStatus.pending,
        description: 'طلب سحب - ${method == 'bank' ? 'تحويل بنكي' : 'محفظة إلكترونية'}',
        createdAt: DateTime.now(),
      );
      
      state = state.copyWith(
        wallet: state.wallet!.copyWith(
          balance: newBalance,
          pendingBalance: newPending,
        ),
        transactions: [newTransaction, ...state.transactions],
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Handle cashout rejection - refund amount + fee
  Future<bool> refundCashout(String transactionId) async {
    try {
      final transaction = state.transactions.firstWhere((t) => t.id == transactionId);
      
      // Refund full amount including fee
      final refundAmount = transaction.amount.abs();
      final newBalance = state.wallet!.balance + refundAmount;
      
      state = state.copyWith(
        wallet: state.wallet!.copyWith(balance: newBalance),
        transactions: state.transactions.map((t) {
          if (t.id == transactionId) {
            return t.copyWith(status: TransactionStatus.cancelled);
          }
          return t;
        }).toList(),
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> transfer(String toWallet, double amount) async {
    try {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(seconds: 1));
      
      if (state.wallet != null && state.wallet!.balance >= amount) {
        final newBalance = state.wallet!.balance - amount;
        state = state.copyWith(
          wallet: state.wallet!.copyWith(balance: newBalance),
          isLoading: false,
        );
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'الرصيد غير كافٍ');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});
