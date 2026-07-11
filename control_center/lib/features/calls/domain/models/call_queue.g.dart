// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CallQueueImpl _$$CallQueueImplFromJson(Map<String, dynamic> json) =>
    _$CallQueueImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      routingStrategy:
          $enumDecodeNullable(
            _$RoutingStrategyEnumMap,
            json['routingStrategy'],
          ) ??
          RoutingStrategy.roundRobin,
      maxWaitTime: (json['maxWaitTime'] as num?)?.toInt() ?? 300,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CallQueueImplToJson(_$CallQueueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'description': instance.description,
      'routingStrategy': _$RoutingStrategyEnumMap[instance.routingStrategy]!,
      'maxWaitTime': instance.maxWaitTime,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$RoutingStrategyEnumMap = {
  RoutingStrategy.roundRobin: 'roundRobin',
  RoutingStrategy.leastRecent: 'leastRecent',
  RoutingStrategy.random: 'random',
};
