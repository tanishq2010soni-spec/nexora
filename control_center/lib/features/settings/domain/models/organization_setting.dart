import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_setting.freezed.dart';
part 'organization_setting.g.dart';

@freezed
class OrganizationSetting with _$OrganizationSetting {
  const factory OrganizationSetting({
    required String id,
    required String orgId,
    required String key,
    required String value,
    String? description,
    String? category,
    required DateTime updatedAt,
  }) = _OrganizationSetting;

  factory OrganizationSetting.fromJson(Map<String, dynamic> json) =>
      _$OrganizationSettingFromJson(json);
}
