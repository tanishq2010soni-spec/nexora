// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WhatsAppConfigImpl _$$WhatsAppConfigImplFromJson(Map<String, dynamic> json) =>
    _$WhatsAppConfigImpl(
      phoneNumberId: json['phoneNumberId'] as String?,
      businessAccountId: json['businessAccountId'] as String?,
      accessToken: json['accessToken'] as String?,
      autoReply: json['autoReply'] as bool? ?? true,
      leadExtraction: json['leadExtraction'] as bool? ?? true,
      quickReplies: (json['quickReplies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$WhatsAppConfigImplToJson(
  _$WhatsAppConfigImpl instance,
) => <String, dynamic>{
  'phoneNumberId': instance.phoneNumberId,
  'businessAccountId': instance.businessAccountId,
  'accessToken': instance.accessToken,
  'autoReply': instance.autoReply,
  'leadExtraction': instance.leadExtraction,
  'quickReplies': instance.quickReplies,
};
