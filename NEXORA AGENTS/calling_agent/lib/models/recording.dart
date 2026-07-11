class Recording {
  final String id;
  final String callId;
  final String? contactName;
  final double duration;
  final DateTime date;
  final String status;
  final String? transcriptionStatus;
  final String? transcriptionText;
  final String? fileUrl;
  final int fileSize;

  const Recording({
    required this.id,
    required this.callId,
    this.contactName,
    this.duration = 0,
    required this.date,
    this.status = 'completed',
    this.transcriptionStatus,
    this.transcriptionText,
    this.fileUrl,
    this.fileSize = 0,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      contactName: json['contact_name'] as String?,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'completed',
      transcriptionStatus: json['transcription_status'] as String?,
      transcriptionText: json['transcription_text'] as String?,
      fileUrl: json['file_url'] as String?,
      fileSize: json['file_size'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_id': callId,
      'contact_name': contactName,
      'duration': duration,
      'date': date.toIso8601String(),
      'status': status,
      'transcription_status': transcriptionStatus,
      'transcription_text': transcriptionText,
      'file_url': fileUrl,
      'file_size': fileSize,
    };
  }
}
