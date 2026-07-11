class Call {
  final String id;
  final String callerNumber;
  final String? callerName;
  final String? agentId;
  final String? agentName;
  final String campaignId;
  final String? campaignName;
  final String status;
  final double duration;
  final String direction;
  final double sentiment;
  final String? transcript;
  final String? recordingUrl;
  final String? disposition;
  final String? notes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? leadId;
  final bool isAiActive;

  const Call({
    required this.id,
    required this.callerNumber,
    this.callerName,
    this.agentId,
    this.agentName,
    required this.campaignId,
    this.campaignName,
    required this.status,
    this.duration = 0,
    this.direction = 'inbound',
    this.sentiment = 0,
    this.transcript,
    this.recordingUrl,
    this.disposition,
    this.notes,
    required this.startedAt,
    this.endedAt,
    this.leadId,
    this.isAiActive = false,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      callerNumber: json['caller_number'] as String,
      callerName: json['caller_name'] as String?,
      agentId: json['agent_id'] as String?,
      agentName: json['agent_name'] as String?,
      campaignId: json['campaign_id'] as String,
      campaignName: json['campaign_name'] as String?,
      status: json['status'] as String,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      direction: json['direction'] as String? ?? 'inbound',
      sentiment: (json['sentiment'] as num?)?.toDouble() ?? 0,
      transcript: json['transcript'] as String?,
      recordingUrl: json['recording_url'] as String?,
      disposition: json['disposition'] as String?,
      notes: json['notes'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      leadId: json['lead_id'] as String?,
      isAiActive: json['is_ai_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caller_number': callerNumber,
      'caller_name': callerName,
      'agent_id': agentId,
      'agent_name': agentName,
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'status': status,
      'duration': duration,
      'direction': direction,
      'sentiment': sentiment,
      'transcript': transcript,
      'recording_url': recordingUrl,
      'disposition': disposition,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'lead_id': leadId,
      'is_ai_active': isAiActive,
    };
  }
}
