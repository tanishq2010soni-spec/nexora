import 'package:freezed_annotation/freezed_annotation.dart';

part 'integration.freezed.dart';
part 'integration.g.dart';

enum IntegrationStatus { connected, disconnected, error }

@freezed
class Integration with _$Integration {
  const factory Integration({
    required String id,
    required String orgId,
    required String name,
    required String type,
    String? description,
    String? logoUrl,
    @Default(IntegrationStatus.disconnected) IntegrationStatus status,
    @Default(<String, String>{}) Map<String, String> config,
    DateTime? connectedAt,
    required DateTime createdAt,
  }) = _Integration;

  factory Integration.fromJson(Map<String, dynamic> json) =>
      _$IntegrationFromJson(json);
}
