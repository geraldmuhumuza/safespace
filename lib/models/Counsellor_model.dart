class Counsellor_Model {
  final String counsellorName;
  final String role;
  final String phone;

  Counsellor_Model({
    required this.counsellorName,
    required this.role,
    required this.phone,
  });

  factory Counsellor_Model.fromJson(Map<String, dynamic> json) {
    return Counsellor_Model(
      counsellorName: 'cousellor_name',
      role: json['Contact_name'],
      phone: json['Phone'],
    );
  }
}
