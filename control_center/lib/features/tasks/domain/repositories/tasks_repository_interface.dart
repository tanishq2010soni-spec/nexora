import '../../../../core/network/api_result.dart';
import '../models/task_model.dart';
import '../models/note.dart';

abstract class TasksRepositoryInterface {
  Future<ApiResult<List<TaskModel>>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? search,
    String? assignedTo,
  });

  Future<ApiResult<TaskModel>> getTask(String id);

  Future<ApiResult<TaskModel>> createTask(TaskModel task);

  Future<ApiResult<TaskModel>> updateTask(String id, TaskModel task);

  Future<ApiResult<void>> deleteTask(String id);

  Future<ApiResult<List<TaskNote>>> getNotes({
    required String entityType,
    required String entityId,
  });

  Future<ApiResult<TaskNote>> addNote({
    required String entityType,
    required String entityId,
    required String content,
  });
}
