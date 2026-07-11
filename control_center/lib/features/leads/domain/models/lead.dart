import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

enum LeadStatus {
  newLead,
  contacted,
  qualified,
  proposalSent,
  negotiation,
  won,
  lost,
}

enum LeadSource { whatsapp, callingAgent, website, manual, import }

@freezed
class Lead with _$Lead {
  const factory Lead({
    required String id,
    required String orgId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? jobTitle,
    @Default(LeadStatus.newLead) LeadStatus status,
    @Default(LeadSource.manual) LeadSource source,
    String? assignedTo,
    String? assignedToName,
    @Default(0) int aiScore,
    @Default(0) int intentScore,
    @Default(0) int budgetScore,
    @Default(0) int engagementScore,
    String? notes,
    Map<String, dynamic>? metadata,
    String? conversationId,
    DateTime? lastContactedAt,
    DateTime? qualifiedAt,
    DateTime? wonAt,
    DateTime? lostAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
}
