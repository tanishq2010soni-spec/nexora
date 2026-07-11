import '../../domain/models/lead.dart';

/// Mapper class to convert between backend LeadResponse and frontend Lead model.
/// Keeps domain models clean and handles field mapping.
class LeadMapper {
  /// Convert backend LeadResponse to frontend Lead model.
  /// Backend: {id, session_id, name, phone, email, intent, product_interest, budget, score, created_at}
  /// Frontend: {id, orgId, name, email, phone, company, jobTitle, status, source, assignedTo, ...}
  static Lead fromBackendResponse(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String? ?? '',
      orgId: '', // Not in backend
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: null, // Not in backend
      jobTitle: null, // Not in backend
      status: _parseIntentToStatus(json['intent'] as String?),
      source: LeadSource.manual, // Not in backend
      assignedTo: null, // Not in backend
      assignedToName: null, // Not in backend
      aiScore: ((json['score'] as num?) ?? 0).toInt(),
      intentScore: 0, // Not in backend
      budgetScore: 0, // Not in backend
      engagementScore: 0, // Not in backend
      notes: null, // Not in backend
      metadata: json['product_interest'] != null
          ? {'product_interest': json['product_interest']}
          : null,
      conversationId: json['session_id'] as String?,
      lastContactedAt: null, // Not in backend
      qualifiedAt: null, // Not in backend
      wonAt: null, // Not in backend
      lostAt: null, // Not in backend
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Convert frontend Lead model to backend LeadRequest (for create/update).
  static Map<String, dynamic> toBackendRequest(Lead lead) {
    return {
      'name': lead.name,
      'phone': lead.phone,
      'email': lead.email,
      'intent': _statusToIntent(lead.status),
      'product_interest': lead.metadata?['product_interest'],
      'budget': lead.metadata?['budget'],
      'score': lead.aiScore.toDouble(),
    };
  }

  /// Convert LeadStatus enum to backend intent string.
  static String _statusToIntent(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return 'inquiry';
      case LeadStatus.contacted:
        return 'inquiry';
      case LeadStatus.qualified:
        return 'purchase';
      case LeadStatus.proposalSent:
        return 'purchase';
      case LeadStatus.negotiation:
        return 'complaint';
      case LeadStatus.won:
        return 'purchase';
      case LeadStatus.lost:
        return 'support';
    }
  }

  /// Convert backend intent string to LeadStatus enum.
  static LeadStatus _parseIntentToStatus(String? intent) {
    switch (intent?.toLowerCase()) {
      case 'purchase':
        return LeadStatus.qualified;
      case 'inquiry':
        return LeadStatus.contacted;
      case 'complaint':
        return LeadStatus.negotiation;
      case 'support':
        return LeadStatus.newLead;
      default:
        return LeadStatus.newLead;
    }
  }
}
