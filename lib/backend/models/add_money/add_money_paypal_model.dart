class AddMoneyHealthPayModel {
  String trx;
  String iframeUrl;
  PaymentInformations paymentInformations;
  String message;

  AddMoneyHealthPayModel({
    required this.trx,
    required this.iframeUrl,
    required this.paymentInformations,
    required this.message,
  });

  factory AddMoneyHealthPayModel.fromJson(Map<String, dynamic> json) {
    return AddMoneyHealthPayModel(
      trx: json['trx'] ?? '',
      iframeUrl: json['iframeUrl'] ?? '',
      message: json['message'] ?? '',
      paymentInformations: json['payment_informations'] != null
          ? PaymentInformations.fromJson(json['payment_informations'])
          : PaymentInformations.empty(), // fallback if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trx': trx,
      'iframeUrl': iframeUrl,
      'message': message,
      'payment_informations': paymentInformations.toJson(),
    };
  }
}

class PaymentInformations {
  String trx;
  String gatewayCurrencyName;
  String requestAmount;
  String exchangeRate;
  String totalCharge;
  String willGet;
  String payableAmount;

  PaymentInformations({
    required this.trx,
    required this.gatewayCurrencyName,
    required this.requestAmount,
    required this.exchangeRate,
    required this.totalCharge,
    required this.willGet,
    required this.payableAmount,
  });

  factory PaymentInformations.fromJson(Map<String, dynamic> json) {
    return PaymentInformations(
      trx: json['trx'] ?? '',
      gatewayCurrencyName: json['gateway_currency_name'] ?? '',
      requestAmount: json['request_amount'] ?? '',
      exchangeRate: json['exchange_rate'] ?? '',
      totalCharge: json['total_charge'] ?? '',
      willGet: json['will_get'] ?? '',
      payableAmount: json['payable_amount'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trx': trx,
      'gateway_currency_name': gatewayCurrencyName,
      'request_amount': requestAmount,
      'exchange_rate': exchangeRate,
      'total_charge': totalCharge,
      'will_get': willGet,
      'payable_amount': payableAmount,
    };
  }

  /// Optional helper to handle null gracefully
  factory PaymentInformations.empty() {
    return PaymentInformations(
      trx: '',
      gatewayCurrencyName: '',
      requestAmount: '',
      exchangeRate: '',
      totalCharge: '',
      willGet: '',
      payableAmount: '',
    );
  }
}
