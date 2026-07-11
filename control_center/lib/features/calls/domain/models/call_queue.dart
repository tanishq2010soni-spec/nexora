import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_queue.freezed.dart';
part 'call_queue.g.dart';

enum RoutingStrategy { roundRobin, leastRecent, random }

@freezed
class CallQueue with _$CallQueue {
  const factory CallQueue({
    required String id,
    required String orgId,
    required String name,
    String? description,
    @Default(RoutingStrategy.roundRobin) RoutingStrategy routingStrategy,
    @Default(300) int maxWaitTime,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _CallQueue;

  factory CallQueue.fromJson(Map<String, dynamic> json) =>
      _$CallQueueFromJson(json);
}
