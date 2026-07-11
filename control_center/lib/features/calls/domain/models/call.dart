import 'package:freezed_annotation/freezed_annotation.dart';

part 'call.freezed.dart';
part 'call.g.dart';

enum CallDirection { inbound, outbound }

enum CallStatus { queued, ringing, inProgress, completed, failed, missed }

enum CallSentiment { positive, neutral, negative }

enum CallOutcome {
  qualified,
  appointmentBooked,
  callbackRequested,
  noAnswer,
  wrongNumber,
}

@freezed
class VoiceCall with _$VoiceCall {
  const factory VoiceCall({
    required String id,
    required String orgId,
    required String agentId,
    required CallDirection direction,
    required String callerNumber,
    required String calleeNumber,
    required CallStatus status,
    DateTime? startedAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    @Default(0) int durationSeconds,
    String? recordingUrl,
    String? transcription,
    CallSentiment? sentiment,
    CallOutcome? outcome,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VoiceCall;

  factory VoiceCall.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallFromJson(json);
}
