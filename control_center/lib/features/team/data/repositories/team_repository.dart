import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/department.dart';
import '../../domain/models/team_model.dart';
import '../../domain/models/role.dart';
import '../../domain/models/team_member.dart';
import '../../domain/repositories/team_repository_interface.dart';
import '../datasources/team_remote_datasource.dart';

class TeamRepository implements TeamRepositoryInterface {
  final TeamRemoteDatasource _datasource;

  const TeamRepository(this._datasource);

  @override
  Future<ApiResult<List<Department>>> getDepartments() async {
    try {
      final response = await _datasource.getDepartments();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final departments = list
            .map((e) => Department.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(departments);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch departments'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Department>> createDepartment(Department department) async {
    try {
      final response = await _datasource.createDepartment(department.toJson());
      if (response.statusCode == 200 && response.data != null) {
        final dept = Department.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(dept);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create department'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<TeamModel>>> getTeams() async {
    try {
      final response = await _datasource.getTeams();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final teams = list
            .map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(teams);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch teams'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<TeamModel>> createTeam(TeamModel team) async {
    try {
      final response = await _datasource.createTeam(team.toJson());
      if (response.statusCode == 200 && response.data != null) {
        final created = TeamModel.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(created);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create team'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Role>>> getRoles() async {
    try {
      final response = await _datasource.getRoles();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final roles = list
            .map((e) => Role.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(roles);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch roles'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Role>> createRole(Role role) async {
    try {
      final response = await _datasource.createRole(role.toJson());
      if (response.statusCode == 200 && response.data != null) {
        final created = Role.fromJson(response.data! as Map<String, dynamic>);
        return ApiSuccess(created);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create role'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<TeamMember>>> getMembers() async {
    try {
      final response = await _datasource.getMembers();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final members = list
            .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(members);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch members'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> getActivity() async {
    try {
      final response = await _datasource.getActivity();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final activity = list.cast<Map<String, dynamic>>();
        return ApiSuccess(activity);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch activity'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
