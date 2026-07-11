import 'package:freezed_annotation/freezed_annotation.dart';

part 'role.freezed.dart';
part 'role.g.dart';

@freezed
class Role with _$Role {
  const factory Role({
    required String id,
    required String orgId,
    required String name,
    String? description,
    @Default(<String>[]) List<String> permissions,
    @Default(0) int memberCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}
