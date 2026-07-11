import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_activity.freezed.dart';
part 'lead_activity.g.dart';

enum ActivityType {
  created,
  statusChanged,
  noteAdded,
  assigned,
  contacted,
  qualified,
  won,
  lost,
  imported,
}

@freezed
class LeadActivity with _$LeadActivity {
  const factory LeadActivity({
    required String id,
    required String leadId,
    required ActivityType type,
    required String description,
    String? performedBy,
    String? oldValue,
    String? newValue,
    required DateTime createdAt,
  }) = _LeadActivity;

  factory LeadActivity.fromJson(Map<String, dynamic> json) =>
      _$LeadActivityFromJson(json);
}
