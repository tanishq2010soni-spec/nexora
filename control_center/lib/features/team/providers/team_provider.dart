import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/team_remote_datasource.dart';
import '../data/repositories/team_repository.dart';
import '../domain/models/department.dart';
import '../domain/models/team_model.dart';
import '../domain/models/role.dart';
import '../domain/models/team_member.dart';
import '../domain/repositories/team_repository_interface.dart';

final teamDatasourceProvider = Provider<TeamRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final teamRepositoryProvider = Provider<TeamRepositoryInterface>((ref) {
  return TeamRepository(ref.read(teamDatasourceProvider));
});

final departmentListProvider = FutureProvider<List<Department>>((ref) async {
  final result = await ref.read(teamRepositoryProvider).getDepartments();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final teamListProvider = FutureProvider<List<TeamModel>>((ref) async {
  final result = await ref.read(teamRepositoryProvider).getTeams();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final roleListProvider = FutureProvider<List<Role>>((ref) async {
  final result = await ref.read(teamRepositoryProvider).getRoles();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final memberListProvider = FutureProvider<List<TeamMember>>((ref) async {
  final result = await ref.read(teamRepositoryProvider).getMembers();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final teamActivityProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final result = await ref.read(teamRepositoryProvider).getActivity();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final createDepartmentProvider = FutureProvider.family<Department, Department>((
  ref,
  dept,
) async {
  final result = await ref.read(teamRepositoryProvider).createDepartment(dept);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final createTeamProvider = FutureProvider.family<TeamModel, TeamModel>((
  ref,
  team,
) async {
  final result = await ref.read(teamRepositoryProvider).createTeam(team);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final createRoleProvider = FutureProvider.family<Role, Role>((ref, role) async {
  final result = await ref.read(teamRepositoryProvider).createRole(role);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
