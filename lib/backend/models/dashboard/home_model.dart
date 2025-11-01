class HomeModel {
  final Data data;

  HomeModel({
    required this.data,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    data: Data.fromJson(json["data"]),
  );
}

class Data {
  final int totalEscrow;
  final int userId;
  final int completedEscrow;
  final int pendingEscrow;
  final int disputeEscrow;
  final List<UserWallet> userWallet;
  final List<DataOfTransaction> transactions;

  Data({
    required this.totalEscrow,
    required this.userId,
    required this.completedEscrow,
    required this.pendingEscrow,
    required this.disputeEscrow,
    required this.userWallet,
    required this.transactions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalEscrow: json["total_escrow"],
    userId: json["user_id"],
    completedEscrow: json["compledted_escrow"],
    pendingEscrow: json["pending_escrow"],
    disputeEscrow: json["dispute_escrow"],
    userWallet: List<UserWallet>.from(json["userWallet"].map((x) => UserWallet.fromJson(x))),
    transactions: List<DataOfTransaction>.from(json["transactions"].map((x) => DataOfTransaction.fromJson(x))),
  );
}
class DataOfTransaction {
  final int id;
  final String trxId;
  final String gatewayCurrency;
  final String transactionType;
  final dynamic senderRequestAmount;
  final String senderCurrencyCode;
  final dynamic totalPayable;
  final String gatewayCurrencyCode;
  final double exchangeRate;
  final double fee;
  final dynamic rejectionReason;
  final dynamic exchangeCurrency;
  final int status;
  final String stringStatus;
  final double balanceAfterTransaction;
  final String createdAt;

  DataOfTransaction({
    required this.id,
    required this.trxId,
    required this.gatewayCurrency,
    required this.transactionType,
    required this.senderRequestAmount,
    required this.senderCurrencyCode,
    required this.totalPayable,
    required this.gatewayCurrencyCode,
    required this.exchangeRate,
    required this.fee,
    required this.rejectionReason,
    required this.exchangeCurrency,
    required this.status,
    required this.stringStatus,
    required this.balanceAfterTransaction,
    required this.createdAt,
  });

  factory DataOfTransaction.fromJson(Map<String, dynamic> json) => DataOfTransaction(
    id: json["id"],
    trxId: json["trx_id"],
    gatewayCurrency: json["gateway_currency"] ?? "EGP",
    transactionType: json["transaction_type"],
    senderRequestAmount: json["sender_request_amount"] ?? "0",
    senderCurrencyCode: json["sender_currency_code"],
    totalPayable: json["total_payable"],
    gatewayCurrencyCode: json["gateway_currency_code"] ?? "0",
    exchangeRate: (json["exchange_rate"] ?? 0).toDouble(),
    fee: (json["fee"] ?? 0).toDouble(),
    rejectionReason: json["rejection_reason"],
    exchangeCurrency: json["exchange_currency"],
    status: json["status"],
    stringStatus: json["string_status"],
    balanceAfterTransaction:
    (json["balance_after_transaction"] ?? 0).toDouble(),
    createdAt: json["created_at"],
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

  factory UserWallet.fromJson(Map<String, dynamic> json) => UserWallet(
    name: json["name"],
    balance: (json["balance"] ?? 0).toDouble(),
    currencyCode: json["currency_code"],
    currencySymbol: json["currency_symbol"],
    currencyType: json["currency_type"],
    rate: (json["rate"] ?? 0).toDouble(),
    flag: json["flag"] ?? "",
    imagePath: json["image_path"],
  );
}