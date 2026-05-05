class Counsellor_Model {
  final int id;
  final String counsellorName;
  final String role;
  final String phone;

  Counsellor_Model({
    required this.id,
    required this.counsellorName,
    required this.role,
    required this.phone,
  });

  factory Counsellor_Model.fromJson(Map<String, dynamic> json) {
    return Counsellor_Model(
      id: json['id'] ?? 0,
      counsellorName: json['counsellorName'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
