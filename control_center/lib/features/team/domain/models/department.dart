import 'package:freezed_annotation/freezed_annotation.dart';

part 'department.freezed.dart';
part 'department.g.dart';

@freezed
class Department with _$Department {
  const factory Department({
    required String id,
    required String orgId,
    required String name,
    String? description,
    String? managerId,
    String? managerName,
    @Default(0) int memberCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
}
