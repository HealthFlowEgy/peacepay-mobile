class DataOfTransaction {
  final int id;
  final dynamic trxId;
  final dynamic gatewayCurrency; // e.g. "EGP"
  final dynamic transactionType; // e.g. "ADD-MONEY"
  final dynamic senderRequestAmount; // normalized to double
  final dynamic senderCurrencyCode;
  final String totalPayable; // normalized to double
  final dynamic
      gatewayCurrencyCode; // keep as String (API sometimes uses codes like "EGP")
  final dynamic exchangeRate;
  final dynamic fee;
  final dynamic rejectionReason;
  final dynamic exchangeCurrency;
  final dynamic status;
  final dynamic stringStatus;
  final dynamic balanceAfterTransaction;
  final dynamic createdAt;

  const DataOfTransaction({
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

  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static double _pickBalanceAfterTx(Map<String, dynamic> json) {
    // Accept common aliases from different endpoints
    const keys = [
      'balance_after_transaction',
      'balance_after',
      'post_balance',
      'after_balance',
      'balanceAfterTransaction',
    ];
    for (final k in keys) {
      final v = json[k];
      if (v != null && v.toString() != 'null') return _toDouble(v);
    }
    return 0.0;
  }

  factory DataOfTransaction.fromJson(Map<String, dynamic> json) =>
      DataOfTransaction(
        id: (json['id'] ?? 0) as int,
        trxId: (json['trx_id'] ?? '') as String,
        gatewayCurrency: (json['gateway_currency'] ?? 'EGP') as String,
        transactionType: (json['transaction_type'] ?? '') as String,
        senderRequestAmount: _toDouble(json['sender_request_amount']),
        senderCurrencyCode: (json['sender_currency_code'] ?? '') as String,
        totalPayable: json['total_payable'],
        gatewayCurrencyCode: (json['gateway_currency_code'] ?? 'EGP') as String,
        exchangeRate: _toDouble(json['exchange_rate']),
        fee: _toDouble(json['fee']),
        rejectionReason: json['rejection_reason']?.toString(),
        exchangeCurrency: json['exchange_currency']?.toString(),
        status: (json['status'] ?? 0) as int,
        stringStatus: (json['string_status'] ?? '') as String,
        balanceAfterTransaction: _pickBalanceAfterTx(json),
        createdAt: (json['created_at'] ?? '') as String,
      );
}
