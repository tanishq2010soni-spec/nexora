class CallEvent {
  final String id;
  final String callId;
  final String type;
  final String? data;
  final DateTime timestamp;

  const CallEvent({
    required this.id,
    required this.callId,
    required this.type,
    this.data,
    required this.timestamp,
  });

  factory CallEvent.fromJson(Map<String, dynamic> json) {
    return CallEvent(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      type: json['type'] as String,
      data: json['data'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_id': callId,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
