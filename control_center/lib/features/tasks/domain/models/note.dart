import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class TaskNote with _$TaskNote {
  const factory TaskNote({
    required String id,
    required String orgId,
    required String entityType,
    required String entityId,
    required String content,
    String? createdBy,
    required DateTime createdAt,
  }) = _TaskNote;

  factory TaskNote.fromJson(Map<String, dynamic> json) =>
      _$TaskNoteFromJson(json);
}
