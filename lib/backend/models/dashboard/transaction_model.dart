import 'data_of_transaction.dart';
import 'package:peacepay/backend/models/dashboard/data_of_transaction.dart';

class TransactionModel {
  final TransactionPage data;
  TransactionModel({required this.data});

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    data: TransactionPage.fromJson(json['data'] ?? const {}),
  );
}

class TransactionPage {
  final Transactions transactions;
  TransactionPage({required this.transactions});

  factory TransactionPage.fromJson(Map<String, dynamic> json) => TransactionPage(
    transactions: Transactions.fromJson(json['transactions'] ?? const {}),
  );
}

class Transactions {
  final List<DataOfTransaction> data;
  final int lastPage;

  Transactions({
    required this.data,
    required this.lastPage,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
    data: (json['data'] as List? ?? [])
        .map((x) => DataOfTransaction.fromJson(x as Map<String, dynamic>))
        .toList(),
    lastPage: (json['last_page'] ?? 1) as int,
  );
}
