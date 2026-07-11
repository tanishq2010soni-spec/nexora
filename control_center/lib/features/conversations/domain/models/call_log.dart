import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_log.freezed.dart';
part 'call_log.g.dart';

enum CallOutcome { answered, missed, voicemail, completed }

enum RecordingStatus { recording, processed, failed, none }

@freezed
class CallLog with _$CallLog {
  const factory CallLog({
    required String id,
    required String conversationId,
    required String agentId,
    required String phoneNumber,
    required int durationSeconds,
    required CallOutcome outcome,
    required RecordingStatus recordingStatus,
    String? transcript,
    String? recordingUrl,
    DateTime? startedAt,
    DateTime? endedAt,
    required DateTime createdAt,
  }) = _CallLog;

  factory CallLog.fromJson(Map<String, dynamic> json) =>
      _$CallLogFromJson(json);
}
