class AppointmentModel {
  final int counsellor_id;
  final DateTime appointmentDate;
  final DateTime appointmentTime;

  AppointmentModel({
    required this.counsellor_id,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      counsellor_id: json['counsellor_id'] ?? 0,
      appointmentDate: DateTime.parse(
        json['appointment_date'] ?? DateTime.now().toString(),
      ),
      appointmentTime: DateTime.parse(
        json['appointment_time'] ?? DateTime.now().toString(),
      ),
    );
  }
}
