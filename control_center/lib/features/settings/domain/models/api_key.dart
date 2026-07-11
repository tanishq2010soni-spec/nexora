import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_key.freezed.dart';
part 'api_key.g.dart';

@freezed
class ApiKey with _$ApiKey {
  const factory ApiKey({
    required String id,
    required String orgId,
    required String name,
    required String keyPrefix,
    String? description,
    @Default(true) bool isActive,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    required List<String> scopes,
    required DateTime createdAt,
  }) = _ApiKey;

  factory ApiKey.fromJson(Map<String, dynamic> json) => _$ApiKeyFromJson(json);
}
