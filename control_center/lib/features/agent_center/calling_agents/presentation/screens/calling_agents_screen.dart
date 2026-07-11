import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../domain/models/calling_agent.dart';
import '../../providers/calling_agent_provider.dart';
import '../widgets/calling_agent_card.dart';
import '../widgets/calling_agent_form.dart';

class CallingAgentsScreen extends ConsumerWidget {
  const CallingAgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(callingAgentsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.pageVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calling Agents',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              AppButton(
                label: 'Create Agent',
                icon: Icons.add,
                onPressed: () => _showCreateForm(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: agentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 16),
                child: ListShimmer(itemCount: 6),
              ),
              error: (error, _) => ErrorView(
                exception: error is AppException
                    ? error
                    : UnknownException(error.toString()),
                onRetry: () => ref.invalidate(callingAgentsProvider),
              ),
              data: (result) => switch (result) {
                ApiSuccess(:final data) =>
                  data.isEmpty
                      ? EmptyState(
                          icon: Icons.phone_disabled_outlined,
                          title: 'No calling agents yet',
                          subtitle:
                              'Create your first calling agent to get started.',
                          action: AppButton(
                            label: 'Create Agent',
                            onPressed: () => _showCreateForm(context, ref),
                          ),
                        )
                      : _AgentGrid(agents: data),
                ApiError(:final exception) => ErrorView(
                  exception: exception,
                  onRetry: () => ref.invalidate(callingAgentsProvider),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CallingAgentForm(
        onSubmit: (agent) async {
          final repository = ref.read(callingAgentRepositoryProvider);
          final result = await repository.createAgent(agent);
          if (context.mounted) {
            Navigator.of(context).pop(result);
            ref.invalidate(callingAgentsProvider);
          }
        },
      ),
    );
  }
}

class _AgentGrid extends StatelessWidget {
  final List<CallingAgent> agents;

  const _AgentGrid({required this.agents});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 1.4,
      ),
      itemCount: agents.length,
      itemBuilder: (context, index) => CallingAgentCard(agent: agents[index]),
    );
  }
}
