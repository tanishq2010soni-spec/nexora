// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceConfigImpl _$$VoiceConfigImplFromJson(Map<String, dynamic> json) =>
    _$VoiceConfigImpl(
      voiceId: json['voiceId'] as String? ?? 'alloy',
      twilioAccountSid: json['twilioAccountSid'] as String?,
      twilioAuthToken: json['twilioAuthToken'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 16000,
      recordCalls: json['recordCalls'] as bool? ?? true,
    );

Map<String, dynamic> _$$VoiceConfigImplToJson(_$VoiceConfigImpl instance) =>
    <String, dynamic>{
      'voiceId': instance.voiceId,
      'twilioAccountSid': instance.twilioAccountSid,
      'twilioAuthToken': instance.twilioAuthToken,
      'phoneNumber': instance.phoneNumber,
      'sampleRate': instance.sampleRate,
      'recordCalls': instance.recordCalls,
    };
