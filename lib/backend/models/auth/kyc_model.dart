class KycModel {
  final Message message;
  final Data data;

  KycModel({
    required this.message,
    required this.data,
  });

  factory KycModel.fromJson(Map<String, dynamic> json) => KycModel(
    message: Message.fromJson(json["message"]),
    data: Data.fromJson(json["data"]),
  );
}

class Message {
  final List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: List<String>.from(json["success"].map((x) => x)),
  );
}

class Data {
  final String statusInfo;
  final String? rejectReason;
  final int kycStatus;
  final List<InputField> inputFields;
  final KycStringStatus kycStringStatus;

  Data({
    required this.statusInfo,
    required this.rejectReason,
    required this.kycStatus,
    required this.inputFields,
    required this.kycStringStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    statusInfo: json["status_info"],
    rejectReason: json["reject_reason"],
    kycStatus: json["kyc_status"],
    inputFields: List<InputField>.from(
        json["input_fields"].map((x) => InputField.fromJson(x))),
    kycStringStatus: KycStringStatus.fromJson(json["kyc_string_status"]),
  );
}

class InputField {
  final String type;
  final String label;
  final String name;
  final bool required;
  final Validation validation;

  InputField({
    required this.type,
    required this.label,
    required this.name,
    required this.required,
    required this.validation,
  });

  factory InputField.fromJson(Map<String, dynamic> json) => InputField(
    type: json["type"],
    label: json["label"],
    name: json["name"],
    required: json["required"],
    validation: Validation.fromJson(json["validation"]),
  );
}

class Validation {
  final int? max;
  final List<String> mimes;
  final int? min;
  final List<String> options;
  final bool required;

  Validation({
    required this.max,
    required this.mimes,
    required this.min,
    required this.options,
    required this.required,
  });

  factory Validation.fromJson(Map<String, dynamic> json) => Validation(
    max: int.tryParse(json["max"].toString()),
    mimes: List<String>.from(json["mimes"].map((x) => x.trim())),
    min: int.tryParse(json["min"].toString()),
    options: List<String>.from(json["options"].map((x) => x)),
    required: json["required"],
  );
}

class KycStringStatus {
  final String className;
  final String value;

  KycStringStatus({
    required this.className,
    required this.value,
  });

  factory KycStringStatus.fromJson(Map<String, dynamic> json) =>
      KycStringStatus(
        className: json["class"],
        value: json["value"],
      );
}
