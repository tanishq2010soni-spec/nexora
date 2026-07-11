import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

enum CustomerSegment { newCustomer, active, vip, atRisk, churned }

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String orgId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? jobTitle,
    String? avatarUrl,
    @Default(CustomerSegment.newCustomer) CustomerSegment segment,
    @Default(0) int healthScore,
    @Default(0) int engagementScore,
    @Default(0) int retentionScore,
    @Default(0) int satisfactionScore,
    @Default(0) int revenueScore,
    String? assignedTo,
    String? assignedToName,
    String? leadId,
    @Default(0) int totalInteractions,
    @Default(0.0) double totalRevenue,
    @Default([]) List<String> tags,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? memory,
    DateTime? lastInteractionAt,
    DateTime? lastPurchaseAt,
    DateTime? churnedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}
