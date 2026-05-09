class CounsellorModel {
  final int id;
  final String counsellorName;
  final String role;
  final String phone;

  CounsellorModel({
    required this.id,
    required this.counsellorName,
    required this.role,
    required this.phone,
  });

  factory CounsellorModel.fromJson(Map<String, dynamic> json) {
    return CounsellorModel(
      id: json['id'] ?? 0,
      counsellorName: json['counsellorName'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
