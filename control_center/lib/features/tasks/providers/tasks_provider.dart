import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/tasks_remote_datasource.dart';
import '../data/repositories/tasks_repository.dart';
import '../domain/models/task_model.dart';
import '../domain/models/note.dart';
import '../domain/repositories/tasks_repository_interface.dart';

final tasksDatasourceProvider = Provider<TasksRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final tasksRepositoryProvider = Provider<TasksRepositoryInterface>((ref) {
  return TasksRepository(ref.read(tasksDatasourceProvider));
});

final taskListProvider = FutureProvider<List<TaskModel>>((ref) async {
  final result = await ref.read(tasksRepositoryProvider).getTasks();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final taskDetailProvider = FutureProvider.family<TaskModel, String>((
  ref,
  id,
) async {
  final result = await ref.read(tasksRepositoryProvider).getTask(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final taskNotesProvider =
    FutureProvider.family<
      List<TaskNote>,
      ({String entityType, String entityId})
    >((ref, params) async {
      final result = await ref
          .read(tasksRepositoryProvider)
          .getNotes(entityType: params.entityType, entityId: params.entityId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final createTaskProvider = FutureProvider.family<TaskModel, TaskModel>((
  ref,
  task,
) async {
  final result = await ref.read(tasksRepositoryProvider).createTask(task);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateTaskProvider =
    FutureProvider.family<TaskModel, ({String id, TaskModel task})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(tasksRepositoryProvider)
          .updateTask(params.id, params.task);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteTaskProvider = FutureProvider.family<void, String>((ref, id) async {
  final result = await ref.read(tasksRepositoryProvider).deleteTask(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final addTaskNoteProvider =
    FutureProvider.family<
      TaskNote,
      ({String entityType, String entityId, String content})
    >((ref, params) async {
      final result = await ref
          .read(tasksRepositoryProvider)
          .addNote(
            entityType: params.entityType,
            entityId: params.entityId,
            content: params.content,
          );
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });
