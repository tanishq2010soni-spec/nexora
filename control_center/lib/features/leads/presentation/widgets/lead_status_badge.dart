import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/lead.dart';

class LeadStatusBadge extends StatelessWidget {
  final LeadStatus status;

  const LeadStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: config.$2.withAlpha(80)),
      ),
      child: Text(
        config.$1,
        style: AppTypography.labelSmall.copyWith(color: config.$2),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  (String, Color) _statusConfig(LeadStatus status) {
    return switch (status) {
      LeadStatus.newLead => ('New', AppColors.info),
      LeadStatus.contacted => ('Contacted', AppColors.warning),
      LeadStatus.qualified => ('Qualified', AppColors.success),
      LeadStatus.proposalSent => ('Proposal', AppColors.accent),
      LeadStatus.negotiation => ('Negotiation', const Color(0xFFF97316)),
      LeadStatus.won => ('Won', AppColors.success),
      LeadStatus.lost => ('Lost', AppColors.error),
    };
  }
}
