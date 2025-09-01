class CheckPinModel {
  final List<String> successMessages;
  final dynamic data;

  CheckPinModel({
    required this.successMessages,
    this.data,
  });

  String? get firstSuccessMessage =>
      successMessages.isNotEmpty ? successMessages.first : null;

  factory CheckPinModel.fromJson(Map<String, dynamic> json) {
    final msg = json['message'] as Map<String, dynamic>? ?? {};
    final success = msg['success'];
    return CheckPinModel(
      successMessages: success is List<String>
          ? success
          : success is List
          ? success.map((e) => e.toString()).toList()
          : <String>[],
      data: json['data'],
    );
  }
}
