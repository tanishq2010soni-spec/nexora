// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      subscriptionId: json['subscriptionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      invoiceUrl: json['invoiceUrl'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'subscriptionId': instance.subscriptionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'invoiceUrl': instance.invoiceUrl,
      'paidAt': instance.paidAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
