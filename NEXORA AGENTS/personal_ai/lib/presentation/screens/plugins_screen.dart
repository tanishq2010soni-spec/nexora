import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';

class PluginsScreen extends StatelessWidget {
  const PluginsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugins')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Installed Plugins', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xl),
            const Expanded(
              child: EmptyState(
                icon: Icons.extension_outlined,
                title: 'No plugins installed',
                subtitle: 'Plugins extend the AI\'s capabilities',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
