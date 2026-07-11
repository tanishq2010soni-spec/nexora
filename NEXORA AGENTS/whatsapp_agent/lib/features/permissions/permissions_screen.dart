import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/permission_provider.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  int? _expandedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();

    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permissions', style: AppTypography.displaySmall),
                const SizedBox(height: 4),
                Text('Manage user roles and permissions', style: AppTypography.bodyMedium),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const AppLoader()
                : provider.users.isEmpty
                    ? Center(child: Text('No users found', style: AppTypography.bodyMedium))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: provider.users.length,
                        itemBuilder: (context, index) => _buildUserCard(provider, provider.users[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(PermissionProvider provider, dynamic user) {
    final isExpanded = _expandedUserId == user.id;
    final perms = provider.availablePermissions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedUserId = isExpanded ? null : user.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      (user.name as String).isNotEmpty ? (user.name as String)[0].toUpperCase() : 'U',
                      style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name as String, style: AppTypography.titleMedium),
                        Text(user.email as String, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  _badge(user.role as String, user.role == 'admin' ? AppColors.primary : user.role == 'agent' ? AppColors.info : AppColors.textMuted),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 4,
                    children: (user.permissions as List<dynamic>).take(3).map<Widget>((p) => _badge(p as String, AppColors.success)).toList(),
                  ),
                  if ((user.permissions as List).length > 3)
                    Text(' +${(user.permissions as List).length - 3}', style: AppTypography.bodySmall),
                  const SizedBox(width: 8),
                  Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.dividerColor),
                  const SizedBox(height: 12),
                  Text('Edit Permissions', style: AppTypography.titleMedium),
                  const SizedBox(height: 12),
                  if (perms.isEmpty)
                    Text('No permissions available', style: AppTypography.bodyMedium)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: perms.map((perm) {
                        final hasPerm = (user.permissions as List<dynamic>).contains(perm);
                        return FilterChip(
                          label: Text(
                            perm.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                            style: AppTypography.bodySmall.copyWith(
                              color: hasPerm ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                          selected: hasPerm,
                          onSelected: (selected) {
                            final updated = List<String>.from(user.permissions as List);
                            if (selected) {
                              updated.add(perm);
                            } else {
                              updated.remove(perm);
                            }
                            provider.updateUserPermissions(user.id, updated);
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                          backgroundColor: AppColors.chipBg,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
