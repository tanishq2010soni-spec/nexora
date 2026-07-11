import '../../domain/models/customer.dart';

/// Mapper class to convert between backend CustomerResponse and frontend Customer model.
/// Keeps domain models clean and handles field mapping.
class CustomerMapper {
  /// Convert backend CustomerResponse to frontend Customer model.
  /// Backend: {id, phone, name, preferences, notes, created_at, updated_at}
  /// Frontend: {id, orgId, name, email, phone, company, ...}
  static Customer fromBackendResponse(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String? ?? '',
      orgId: '', // Not in backend
      name: json['name'] as String? ?? 'Unknown',
      email: null, // Not in backend
      phone: json['phone'] as String?,
      company: null, // Not in backend
      jobTitle: null, // Not in backend
      avatarUrl: null, // Not in backend
      segment: CustomerSegment.newCustomer, // Not in backend
      healthScore: 0, // Not in backend
      engagementScore: 0, // Not in backend
      retentionScore: 0, // Not in backend
      satisfactionScore: 0, // Not in backend
      revenueScore: 0, // Not in backend
      assignedTo: null, // Not in backend
      assignedToName: null, // Not in backend
      leadId: null, // Not in backend
      totalInteractions: 0, // Not in backend
      totalRevenue: 0.0, // Not in backend
      tags: [], // Not in backend
      preferences: _parsePreferences(json['preferences'] as String?),
      memory: null, // Not in backend
      lastInteractionAt: null, // Not in backend
      lastPurchaseAt: null, // Not in backend
      churnedAt: null, // Not in backend
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Convert frontend Customer model to backend CustomerUpdate request.
  static Map<String, dynamic> toBackendUpdateRequest(Customer customer) {
    final data = <String, dynamic>{};
    if (customer.name.isNotEmpty) data['name'] = customer.name;
    if (customer.preferences != null) {
      data['preferences'] = customer.preferences.toString();
    }
    return data;
  }

  /// Parse preferences string to Map (backend stores as string).
  static Map<String, dynamic>? _parsePreferences(String? prefs) {
    if (prefs == null || prefs.isEmpty) return null;
    // Backend stores preferences as a string, try to parse as JSON
    try {
      // If it's already a JSON string, parse it
      if (prefs.startsWith('{')) {
        return Map<String, dynamic>.from(
          Map.castFrom(Uri.splitQueryString(prefs) as Map<String, dynamic>),
        );
      }
      // Otherwise treat as key=value pairs
      return {'raw': prefs};
    } catch (_) {
      return {'raw': prefs};
    }
  }
}
