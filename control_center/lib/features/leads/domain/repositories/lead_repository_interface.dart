import '../../../../core/network/api_result.dart';
import '../models/lead.dart';
import '../models/lead_activity.dart';
import '../models/lead_analytics.dart';
import '../models/lead_note.dart';

abstract class LeadRepositoryInterface {
  Future<ApiResult<List<Lead>>> getLeads({
    LeadStatus? status,
    LeadSource? source,
    String? search,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  });

  Future<ApiResult<Lead>> getLead(String id);

  Future<ApiResult<Lead>> createLead(Lead lead);

  Future<ApiResult<Lead>> updateLead(String id, Lead lead);

  Future<ApiResult<void>> deleteLead(String id);

  Future<ApiResult<void>> deleteLeads(List<String> ids);

  Future<ApiResult<Lead>> updateStatus(String id, LeadStatus status);

  Future<ApiResult<Lead>> assignLead(String id, String userId);

  Future<ApiResult<List<LeadActivity>>> getActivities(String leadId);

  Future<ApiResult<LeadNote>> addNote(String leadId, String content);

  Future<ApiResult<LeadAnalytics>> getAnalytics();

  Future<ApiResult<List<Lead>>> searchLeads(
    String query, {
    LeadStatus? status,
    LeadSource? source,
  });

  Future<ApiResult<String>> exportCsv({LeadStatus? status, LeadSource? source});
}
