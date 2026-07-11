import 'package:freezed_annotation/freezed_annotation.dart';

part 'whatsapp_config.freezed.dart';
part 'whatsapp_config.g.dart';

@freezed
class WhatsAppConfig with _$WhatsAppConfig {
  const factory WhatsAppConfig({
    String? phoneNumberId,
    String? businessAccountId,
    String? accessToken,
    @Default(true) bool autoReply,
    @Default(true) bool leadExtraction,
    Map<String, String>? quickReplies,
  }) = _WhatsAppConfig;

  factory WhatsAppConfig.fromJson(Map<String, dynamic> json) =>
      _$WhatsAppConfigFromJson(json);
}
