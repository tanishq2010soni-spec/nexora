import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_note.freezed.dart';
part 'lead_note.g.dart';

@freezed
class LeadNote with _$LeadNote {
  const factory LeadNote({
    required String id,
    required String leadId,
    required String content,
    required String authorName,
    required DateTime createdAt,
  }) = _LeadNote;

  factory LeadNote.fromJson(Map<String, dynamic> json) =>
      _$LeadNoteFromJson(json);
}
