import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/task_model.dart';
import '../../domain/models/note.dart';
import '../../domain/repositories/tasks_repository_interface.dart';
import '../datasources/tasks_remote_datasource.dart';

class TasksRepository implements TasksRepositoryInterface {
  final TasksRemoteDatasource _datasource;

  const TasksRepository(this._datasource);

  @override
  Future<ApiResult<List<TaskModel>>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? search,
    String? assignedTo,
  }) async {
    try {
      final response = await _datasource.getTasks(
        status: status?.name,
        priority: priority?.name,
        search: search,
        assignedTo: assignedTo,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final tasks = list
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(tasks);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch tasks'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<TaskModel>> getTask(String id) async {
    try {
      final response = await _datasource.getTask(id);
      if (response.statusCode == 200 && response.data != null) {
        final task = TaskModel.fromJson(response.data! as Map<String, dynamic>);
        return ApiSuccess(task);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch task'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<TaskModel>> createTask(TaskModel task) async {
    try {
      final response = await _datasource.createTask(task.toJson());
      if (response.statusCode == 200 && response.data != null) {
        final created = TaskModel.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(created);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create task'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<TaskModel>> updateTask(String id, TaskModel task) async {
    try {
      final response = await _datasource.updateTask(id, task.toJson());
      if (response.statusCode == 200 && response.data != null) {
        final updated = TaskModel.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(updated);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to update task'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteTask(String id) async {
    try {
      final response = await _datasource.deleteTask(id);
      if (response.statusCode == 200) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to delete task'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<TaskNote>>> getNotes({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final response = await _datasource.getNotes(
        entityType: entityType,
        entityId: entityId,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final notes = list
            .map((e) => TaskNote.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(notes);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch notes'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<TaskNote>> addNote({
    required String entityType,
    required String entityId,
    required String content,
  }) async {
    try {
      final response = await _datasource.addNote(
        entityType: entityType,
        entityId: entityId,
        content: content,
      );
      if (response.statusCode == 200 && response.data != null) {
        final note = TaskNote.fromJson(response.data! as Map<String, dynamic>);
        return ApiSuccess(note);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to add note'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
