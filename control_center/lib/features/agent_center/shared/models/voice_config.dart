import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_config.freezed.dart';
part 'voice_config.g.dart';

@freezed
class VoiceConfig with _$VoiceConfig {
  const factory VoiceConfig({
    @Default('alloy') String voiceId,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? phoneNumber,
    @Default(16000) int sampleRate,
    @Default(true) bool recordCalls,
  }) = _VoiceConfig;

  factory VoiceConfig.fromJson(Map<String, dynamic> json) =>
      _$VoiceConfigFromJson(json);
}
