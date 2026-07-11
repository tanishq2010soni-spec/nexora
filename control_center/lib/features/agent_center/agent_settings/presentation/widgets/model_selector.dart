import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../domain/models/available_model.dart';

class ModelSelector extends StatelessWidget {
  final List<AvailableModel> models;
  final String? selectedModelId;
  final ValueChanged<String?> onModelChanged;

  const ModelSelector({
    super.key,
    required this.models,
    this.selectedModelId,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Selection',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedModelId,
          onChanged: onModelChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: models.map((model) {
            return DropdownMenuItem<String>(
              value: model.id,
              enabled: model.isAvailable,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              model.name,
                              style: AppTypography.bodyMedium.copyWith(
                                color: model.isAvailable
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                model.provider,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (model.description != null)
                          Text(
                            model.description!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (!model.isAvailable)
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
