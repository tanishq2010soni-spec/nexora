import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/network/api_result.dart';
import '../data/datasources/template_remote_datasource.dart';
import '../data/repositories/template_repository.dart';
import '../domain/models/agent_template.dart';
import '../domain/repositories/template_repository_interface.dart';

final templateDatasourceProvider = Provider<TemplateRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final templateRepositoryProvider = Provider<TemplateRepositoryInterface>((ref) {
  return TemplateRepository(ref.read(templateDatasourceProvider));
});

final templateListProvider = FutureProvider<List<AgentTemplate>>((ref) async {
  final result = await ref.read(templateRepositoryProvider).getTemplates();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final createTemplateProvider =
    NotifierProvider<CreateTemplateNotifier, AsyncValue<AgentTemplate?>>(
      CreateTemplateNotifier.new,
    );

class CreateTemplateNotifier extends Notifier<AsyncValue<AgentTemplate?>> {
  @override
  AsyncValue<AgentTemplate?> build() => const AsyncData(null);

  Future<bool> create(AgentTemplate template) async {
    state = const AsyncLoading();
    final result = await ref
        .read(templateRepositoryProvider)
        .createTemplate(template);
    return switch (result) {
      ApiSuccess(data: final data) => _onSuccess(data),
      ApiError(exception: final exception) => _onError(exception),
      _ => _onError(const UnknownException('Unknown error')),
    };
  }

  bool _onSuccess(AgentTemplate template) {
    state = AsyncData(template);
    ref.invalidate(templateListProvider);
    return true;
  }

  bool _onError(AppException exception) {
    state = AsyncError(exception, StackTrace.current);
    return false;
  }
}

final duplicateTemplateProvider =
    NotifierProvider<DuplicateTemplateNotifier, AsyncValue<AgentTemplate?>>(
      DuplicateTemplateNotifier.new,
    );

class DuplicateTemplateNotifier extends Notifier<AsyncValue<AgentTemplate?>> {
  @override
  AsyncValue<AgentTemplate?> build() => const AsyncData(null);

  Future<bool> duplicate(String id, String newName) async {
    state = const AsyncLoading();
    final result = await ref
        .read(templateRepositoryProvider)
        .duplicateTemplate(id, newName);
    return switch (result) {
      ApiSuccess(data: final data) => _onSuccess(data),
      ApiError(exception: final exception) => _onError(exception),
      _ => _onError(const UnknownException('Unknown error')),
    };
  }

  bool _onSuccess(AgentTemplate template) {
    state = AsyncData(template);
    ref.invalidate(templateListProvider);
    return true;
  }

  bool _onError(AppException exception) {
    state = AsyncError(exception, StackTrace.current);
    return false;
  }
}

final deleteTemplateProvider =
    NotifierProvider<DeleteTemplateNotifier, AsyncValue<void>>(
      DeleteTemplateNotifier.new,
    );

class DeleteTemplateNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final result = await ref
        .read(templateRepositoryProvider)
        .deleteTemplate(id);
    return switch (result) {
      ApiSuccess() => _onSuccess(),
      ApiError(exception: final exception) => _onError(exception),
      _ => _onError(const UnknownException('Unknown error')),
    };
  }

  bool _onSuccess() {
    state = const AsyncData(null);
    ref.invalidate(templateListProvider);
    return true;
  }

  bool _onError(AppException exception) {
    state = AsyncError(exception, StackTrace.current);
    return false;
  }
}
