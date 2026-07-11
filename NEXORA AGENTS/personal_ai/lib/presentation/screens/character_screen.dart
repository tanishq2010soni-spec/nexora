import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/character_provider.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final character = context.watch<CharacterProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Character')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            FadeIn(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.face,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    if (character.isAnimating)
                      Positioned(
                        bottom: 20,
                        child: SizedBox(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Dot(character.expression == 'thinking', AppColors.warning),
                              const SizedBox(width: 4),
                              _Dot(character.expression == 'talking', AppColors.accent),
                              const SizedBox(width: 4),
                              const _Dot(false, AppColors.textTertiary),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _expressionTitle(character.expression),
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _expressionColor(character.expression).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                character.expression.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: _expressionColor(character.expression),
                  letterSpacing: 1,
                ),
              ),
            ),
            if (character.message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  character.message!,
                  style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            const Divider(color: AppColors.surfaceBorder),
            const SizedBox(height: AppSpacing.lg),
            Text('Expression Controls', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ExpressionButton(
                  label: 'Idle',
                  icon: Icons.person_outline,
                  selected: character.expression == 'idle',
                  onTap: () => character.setExpression('idle'),
                ),
                _ExpressionButton(
                  label: 'Talking',
                  icon: Icons.chat_outlined,
                  selected: character.expression == 'talking',
                  onTap: () => character.startTalking(),
                ),
                _ExpressionButton(
                  label: 'Thinking',
                  icon: Icons.psychology_outlined,
                  selected: character.expression == 'thinking',
                  onTap: () => character.startThinking(),
                ),
                _ExpressionButton(
                  label: 'Listening',
                  icon: Icons.hearing_outlined,
                  selected: character.expression == 'listening',
                  onTap: () => character.setExpression('listening'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Divider(color: AppColors.surfaceBorder),
            const SizedBox(height: AppSpacing.lg),
            Text('Say Something', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Hello!',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => character.setMessage('Hello! How can I help you today?'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Thinking...',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => character.setMessage('Let me think about that...'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Goodbye',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => character.setMessage('Goodbye! Have a great day!'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Clear',
                    variant: AppButtonVariant.text,
                    onPressed: () => character.setMessage(null),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _expressionTitle(String expr) {
    switch (expr) {
      case 'talking':
        return 'I\'m listening and responding';
      case 'thinking':
        return 'Processing your request...';
      case 'listening':
        return 'Waiting for your input';
      default:
        return 'Ready to assist you';
    }
  }

  Color _expressionColor(String expr) {
    switch (expr) {
      case 'talking':
        return AppColors.accent;
      case 'thinking':
        return AppColors.warning;
      case 'listening':
        return AppColors.primary;
      default:
        return AppColors.textTertiary;
    }
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final Color color;

  const _Dot(this.active, this.color);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : color.withValues(alpha: 0.3),
      ),
    );
  }
}

class _ExpressionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ExpressionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.surfaceBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
