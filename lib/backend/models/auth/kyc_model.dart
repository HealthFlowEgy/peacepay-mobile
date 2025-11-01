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
  final InnerData? innerData; // represents "data" object inside main "data"

  Data({
    required this.statusInfo,
    required this.rejectReason,
    required this.kycStatus,
    required this.inputFields,
    required this.kycStringStatus,
    this.innerData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    statusInfo: json["status_info"],
    rejectReason: json["reject_reason"],
    kycStatus: json["kyc_status"],
    inputFields: json["input_fields"] != null
        ? List<InputField>.from(
        json["input_fields"].map((x) => InputField.fromJson(x)))
        : [],
    kycStringStatus:
    KycStringStatus.fromJson(json["kyc_string_status"]),
    innerData:
    json["data"] != null ? InnerData.fromJson(json["data"]) : null,
  );
}

class InnerData {
  final int id;
  final int userId;
  final List<InputField> data;
  final String rejectReason;
  final String createdAt;
  final String updatedAt;

  InnerData({
    required this.id,
    required this.userId,
    required this.data,
    required this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InnerData.fromJson(Map<String, dynamic> json) => InnerData(
    id: json["id"],
    userId: json["user_id"],
    data: List<InputField>.from(
        json["data"].map((x) => InputField.fromJson(x))),
    rejectReason: json["reject_reason"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );
}

class InputField {
  final String type;
  final String label;
  final String name;
  final bool required;
  final Validation validation;
  final String? value;

  InputField({
    required this.type,
    required this.label,
    required this.name,
    required this.required,
    required this.validation,
    this.value,
  });

  factory InputField.fromJson(Map<String, dynamic> json) => InputField(
    type: json["type"],
    label: json["label"],
    name: json["name"],
    required: json["required"],
    validation: Validation.fromJson(json["validation"]),
    value: json["value"],
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
