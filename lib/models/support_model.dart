class Support_Model {
  final String support_title;
  final String Support_subtitle;
  final String Support_contact;

  Support_Model({
    required this.support_title,
    required this.Support_subtitle,
    required this.Support_contact,
  });

  factory Support_Model.fromJson(Map<String, dynamic> json) {
    return Support_Model(
      support_title: 'support_title',
      Support_subtitle: json['Support_subtitle'],
      Support_contact: json['Support_contact'],
    );
  }
}
