// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceCallImpl _$$VoiceCallImplFromJson(Map<String, dynamic> json) =>
    _$VoiceCallImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      agentId: json['agentId'] as String,
      direction: $enumDecode(_$CallDirectionEnumMap, json['direction']),
      callerNumber: json['callerNumber'] as String,
      calleeNumber: json['calleeNumber'] as String,
      status: $enumDecode(_$CallStatusEnumMap, json['status']),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      answeredAt: json['answeredAt'] == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      recordingUrl: json['recordingUrl'] as String?,
      transcription: json['transcription'] as String?,
      sentiment: $enumDecodeNullable(_$CallSentimentEnumMap, json['sentiment']),
      outcome: $enumDecodeNullable(_$CallOutcomeEnumMap, json['outcome']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VoiceCallImplToJson(_$VoiceCallImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'agentId': instance.agentId,
      'direction': _$CallDirectionEnumMap[instance.direction]!,
      'callerNumber': instance.callerNumber,
      'calleeNumber': instance.calleeNumber,
      'status': _$CallStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt?.toIso8601String(),
      'answeredAt': instance.answeredAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'recordingUrl': instance.recordingUrl,
      'transcription': instance.transcription,
      'sentiment': _$CallSentimentEnumMap[instance.sentiment],
      'outcome': _$CallOutcomeEnumMap[instance.outcome],
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CallDirectionEnumMap = {
  CallDirection.inbound: 'inbound',
  CallDirection.outbound: 'outbound',
};

const _$CallStatusEnumMap = {
  CallStatus.queued: 'queued',
  CallStatus.ringing: 'ringing',
  CallStatus.inProgress: 'inProgress',
  CallStatus.completed: 'completed',
  CallStatus.failed: 'failed',
  CallStatus.missed: 'missed',
};

const _$CallSentimentEnumMap = {
  CallSentiment.positive: 'positive',
  CallSentiment.neutral: 'neutral',
  CallSentiment.negative: 'negative',
};

const _$CallOutcomeEnumMap = {
  CallOutcome.qualified: 'qualified',
  CallOutcome.appointmentBooked: 'appointmentBooked',
  CallOutcome.callbackRequested: 'callbackRequested',
  CallOutcome.noAnswer: 'noAnswer',
  CallOutcome.wrongNumber: 'wrongNumber',
};
