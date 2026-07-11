import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/lead_remote_datasource.dart';
import '../data/repositories/lead_repository.dart';
import '../domain/models/lead.dart';
import '../domain/models/lead_activity.dart';
import '../domain/models/lead_analytics.dart';
import '../domain/models/lead_note.dart';
import '../domain/repositories/lead_repository_interface.dart';

final leadDatasourceProvider = Provider<LeadRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final leadRepositoryProvider = Provider<LeadRepositoryInterface>((ref) {
  return LeadRepository(ref.read(leadDatasourceProvider));
});

final leadListProvider = FutureProvider<List<Lead>>((ref) async {
  final result = await ref.read(leadRepositoryProvider).getLeads();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final leadDetailProvider = FutureProvider.family<Lead, String>((ref, id) async {
  final result = await ref.read(leadRepositoryProvider).getLead(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final leadActivitiesProvider =
    FutureProvider.family<List<LeadActivity>, String>((ref, leadId) async {
      final result = await ref
          .read(leadRepositoryProvider)
          .getActivities(leadId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final leadAnalyticsProvider = FutureProvider<LeadAnalytics>((ref) async {
  final result = await ref.read(leadRepositoryProvider).getAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final leadSearchProvider =
    FutureProvider.family<
      List<Lead>,
      ({String query, String? status, String? source})
    >((ref, params) async {
      LeadStatus? statusFilter;
      LeadSource? sourceFilter;

      if (params.status != null) {
        statusFilter = LeadStatus.values.firstWhere(
          (e) => e.name == params.status,
          orElse: () => LeadStatus.newLead,
        );
      }
      if (params.source != null) {
        sourceFilter = LeadSource.values.firstWhere(
          (e) => e.name == params.source,
          orElse: () => LeadSource.manual,
        );
      }

      final result = await ref
          .read(leadRepositoryProvider)
          .searchLeads(
            params.query,
            status: statusFilter,
            source: sourceFilter,
          );
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final createLeadProvider = FutureProvider.family<Lead, Lead>((ref, lead) async {
  final result = await ref.read(leadRepositoryProvider).createLead(lead);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateLeadProvider =
    FutureProvider.family<Lead, ({String id, Lead lead})>((ref, params) async {
      final result = await ref
          .read(leadRepositoryProvider)
          .updateLead(params.id, params.lead);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteLeadProvider = FutureProvider.family<void, String>((ref, id) async {
  final result = await ref.read(leadRepositoryProvider).deleteLead(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateLeadStatusProvider =
    FutureProvider.family<Lead, ({String id, String status})>((
      ref,
      params,
    ) async {
      final status = LeadStatus.values.firstWhere(
        (e) => e.name == params.status,
        orElse: () => LeadStatus.newLead,
      );
      final result = await ref
          .read(leadRepositoryProvider)
          .updateStatus(params.id, status);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final assignLeadProvider =
    FutureProvider.family<Lead, ({String id, String userId})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(leadRepositoryProvider)
          .assignLead(params.id, params.userId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final addLeadNoteProvider =
    FutureProvider.family<LeadNote, ({String leadId, String content})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(leadRepositoryProvider)
          .addNote(params.leadId, params.content);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final exportLeadsCsvProvider = FutureProvider<String>((ref) async {
  final result = await ref.read(leadRepositoryProvider).exportCsv();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
