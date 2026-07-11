import '../../../../core/network/api_result.dart';
import '../models/department.dart';
import '../models/team_model.dart';
import '../models/role.dart';
import '../models/team_member.dart';

abstract class TeamRepositoryInterface {
  Future<ApiResult<List<Department>>> getDepartments();

  Future<ApiResult<Department>> createDepartment(Department department);

  Future<ApiResult<List<TeamModel>>> getTeams();

  Future<ApiResult<TeamModel>> createTeam(TeamModel team);

  Future<ApiResult<List<Role>>> getRoles();

  Future<ApiResult<Role>> createRole(Role role);

  Future<ApiResult<List<TeamMember>>> getMembers();

  Future<ApiResult<List<Map<String, dynamic>>>> getActivity();
}
