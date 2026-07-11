class Appointment {
  final String id;
  final String title;
  final String? contactId;
  final String? contactName;
  final DateTime dateTime;
  final String status;
  final String? assignedTo;
  final String? notes;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.title,
    this.contactId,
    this.contactName,
    required this.dateTime,
    this.status = 'scheduled',
    this.assignedTo,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      title: json['title'] as String,
      contactId: json['contact_id'] as String?,
      contactName: json['contact_name'] as String?,
      dateTime: DateTime.parse(json['date_time'] as String),
      status: json['status'] as String? ?? 'scheduled',
      assignedTo: json['assigned_to'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contact_id': contactId,
      'contact_name': contactName,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'assigned_to': assignedTo,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
