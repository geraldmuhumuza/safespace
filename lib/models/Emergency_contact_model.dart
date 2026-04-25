class EmergencyContact {
  final int id;
  final String contactName;
  final String phone;

  EmergencyContact({
    required this.id,
    required this.contactName,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      contactName: json['Contact_name'],
      phone: json['Phone'],
    );
  }
}
