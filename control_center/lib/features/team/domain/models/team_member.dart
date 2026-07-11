import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member.freezed.dart';
part 'team_member.g.dart';

@freezed
class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String orgId,
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
    String? departmentId,
    String? departmentName,
    String? teamId,
    String? teamName,
    String? roleId,
    String? roleName,
    @Default('active') String status,
    DateTime? lastActiveAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
}
