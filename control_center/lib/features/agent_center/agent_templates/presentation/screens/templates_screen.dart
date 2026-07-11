import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/empty_state.dart';
import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/widgets/error_view.dart';
import '../../domain/models/agent_template.dart';
import '../../providers/template_provider.dart';
import '../widgets/template_card.dart';
import '../widgets/template_form.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agent Templates',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              AppButton(
                label: 'Create Template',
                icon: Icons.add,
                onPressed: () => _showCreateDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: templatesAsync.when(
              loading: () => const AppLoader(),
              error: (err, _) => ErrorView(
                exception: UnknownException(err.toString()),
                onRetry: () => ref.invalidate(templateListProvider),
              ),
              data: (templates) {
                if (templates.isEmpty) {
                  return EmptyState(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'No templates yet',
                    subtitle: 'Create your first agent template to get started',
                    action: AppButton(
                      label: 'Create Template',
                      icon: Icons.add,
                      onPressed: () => _showCreateDialog(context, ref),
                    ),
                  );
                }
                return _TemplateGrid(templates: templates);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: TemplateForm(
              onSubmit: (template) async {
                final notifier = ref.read(createTemplateProvider.notifier);
                final success = await notifier.create(template);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  final List<AgentTemplate> templates;

  const _TemplateGrid({required this.templates});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 1.1,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return TemplateCard(template: template, onUse: () {});
      },
    );
  }
}
