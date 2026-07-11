import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_note.freezed.dart';
part 'customer_note.g.dart';

@freezed
class CustomerNote with _$CustomerNote {
  const factory CustomerNote({
    required String id,
    required String customerId,
    required String content,
    String? authorId,
    String? authorName,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CustomerNote;

  factory CustomerNote.fromJson(Map<String, dynamic> json) =>
      _$CustomerNoteFromJson(json);
}
