class WathqCrInfoModel {
  final String name;
  final String type;
  final String status;

  WathqCrInfoModel({
    required this.name,
    required this.type,
    required this.status,
  });

  factory WathqCrInfoModel.fromJson(Map<String, dynamic> json) {
    return WathqCrInfoModel(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
