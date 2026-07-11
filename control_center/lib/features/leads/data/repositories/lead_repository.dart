import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/lead.dart';
import '../../domain/models/lead_activity.dart';
import '../../domain/models/lead_analytics.dart';
import '../../domain/models/lead_note.dart';
import '../../domain/repositories/lead_repository_interface.dart';
import '../datasources/lead_remote_datasource.dart';
import '../mappers/lead_mapper.dart';

class LeadRepository implements LeadRepositoryInterface {
  final LeadRemoteDatasource _datasource;

  const LeadRepository(this._datasource);

  @override
  Future<ApiResult<List<Lead>>> getLeads({
    LeadStatus? status,
    LeadSource? source,
    String? search,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _datasource.getLeads(
        status: status?.name,
        source: source?.name,
        search: search,
        assignedTo: assignedTo,
        page: page,
        limit: limit,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final leads = list
            .map(
              (e) => LeadMapper.fromBackendResponse(e as Map<String, dynamic>),
            )
            .toList();
        return ApiSuccess(leads);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch leads'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Lead>> getLead(String id) async {
    try {
      final response = await _datasource.getLead(id);
      if (response.statusCode == 200 && response.data != null) {
        final lead = LeadMapper.fromBackendResponse(response.data!);
        return ApiSuccess(lead);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch lead'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Lead>> createLead(Lead lead) async {
    try {
      return ApiError(
        ServerException('Create lead endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Lead>> updateLead(String id, Lead lead) async {
    try {
      return ApiError(
        ServerException('Update lead endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteLead(String id) async {
    try {
      final response = await _datasource.deleteLead(id);
      if (response.statusCode == 200) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to delete lead'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteLeads(List<String> ids) async {
    try {
      return ApiError(
        ServerException('Bulk delete endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Lead>> updateStatus(String id, LeadStatus status) async {
    try {
      return ApiError(
        ServerException('Update status endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Lead>> assignLead(String id, String userId) async {
    try {
      return ApiError(
        ServerException('Assign lead endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<LeadActivity>>> getActivities(String leadId) async {
    try {
      return ApiError(
        ServerException('Activities endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<LeadNote>> addNote(String leadId, String content) async {
    try {
      return ApiError(
        ServerException('Add note endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<LeadAnalytics>> getAnalytics() async {
    try {
      return ApiError(
        ServerException('Analytics endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Lead>>> searchLeads(
    String query, {
    LeadStatus? status,
    LeadSource? source,
  }) async {
    try {
      return ApiError(
        ServerException('Search endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<String>> exportCsv({
    LeadStatus? status,
    LeadSource? source,
  }) async {
    try {
      return ApiError(
        ServerException('Export CSV endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
