// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CallLogImpl _$$CallLogImplFromJson(Map<String, dynamic> json) =>
    _$CallLogImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      agentId: json['agentId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      outcome: $enumDecode(_$CallOutcomeEnumMap, json['outcome']),
      recordingStatus: $enumDecode(
        _$RecordingStatusEnumMap,
        json['recordingStatus'],
      ),
      transcript: json['transcript'] as String?,
      recordingUrl: json['recordingUrl'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CallLogImplToJson(_$CallLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'agentId': instance.agentId,
      'phoneNumber': instance.phoneNumber,
      'durationSeconds': instance.durationSeconds,
      'outcome': _$CallOutcomeEnumMap[instance.outcome]!,
      'recordingStatus': _$RecordingStatusEnumMap[instance.recordingStatus]!,
      'transcript': instance.transcript,
      'recordingUrl': instance.recordingUrl,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$CallOutcomeEnumMap = {
  CallOutcome.answered: 'answered',
  CallOutcome.missed: 'missed',
  CallOutcome.voicemail: 'voicemail',
  CallOutcome.completed: 'completed',
};

const _$RecordingStatusEnumMap = {
  RecordingStatus.recording: 'recording',
  RecordingStatus.processed: 'processed',
  RecordingStatus.failed: 'failed',
  RecordingStatus.none: 'none',
};
