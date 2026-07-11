import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_activity.freezed.dart';
part 'customer_activity.g.dart';

enum CustomerActivityType {
  leadConverted,
  whatsappInteraction,
  callInteraction,
  noteAdded,
  statusChanged,
  segmentChanged,
}

@freezed
class CustomerActivity with _$CustomerActivity {
  const factory CustomerActivity({
    required String id,
    required String customerId,
    required CustomerActivityType type,
    required String description,
    String? performedBy,
    String? performedByName,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _CustomerActivity;

  factory CustomerActivity.fromJson(Map<String, dynamic> json) =>
      _$CustomerActivityFromJson(json);
}
