import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

@freezed
class TeamModel with _$TeamModel {
  const factory TeamModel({
    required String id,
    required String orgId,
    required String name,
    String? description,
    String? departmentId,
    String? departmentName,
    String? leadId,
    String? leadName,
    @Default(0) int memberCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TeamModel;

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);
}
