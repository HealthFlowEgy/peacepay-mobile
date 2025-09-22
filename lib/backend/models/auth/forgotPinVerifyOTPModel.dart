class ForgetPinVerifyOtpModel {
  final Message message;
  final OtpData data;

  ForgetPinVerifyOtpModel({
    required this.message,
    required this.data,
  });

  factory ForgetPinVerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return ForgetPinVerifyOtpModel(
      message: Message.fromJson(json['message'] ?? const {}),
      data: OtpData.fromJson(json['data'] ?? const {}),
    );
  }
}

class Message {
  final List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) {
    final raw = json['success'];
    // Accept either a list of strings or a single string
    if (raw is List) {
      return Message(success: raw.map((e) => e.toString()).toList());
    } else if (raw is String) {
      return Message(success: [raw]);
    } else {
      return Message(success: const []);
    }
  }
}

class OtpData {
  final String token;

  OtpData({required this.token});

  factory OtpData.fromJson(Map<String, dynamic> json) {
    // Adjust the key if your backend uses a different name (e.g., 'otp_token')
    final tok = json['reset_token'] ?? json['reset_token'] ?? json['reset_token'];
    return OtpData(token: tok?.toString() ?? '');
  }
}
