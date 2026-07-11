import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/department.dart';
import '../../domain/models/team_model.dart';
import '../../domain/models/role.dart';
import '../../providers/team_provider.dart';
import '../widgets/member_tile.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(),
                _buildDepartmentsTab(),
                _buildTeamsTab(),
                _buildRolesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Team Management',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.surfaceBorder,
        tabs: const [
          Tab(text: 'Members'),
          Tab(text: 'Departments'),
          Tab(text: 'Teams'),
          Tab(text: 'Roles'),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    final membersAsync = ref.watch(memberListProvider);

    return membersAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(memberListProvider),
      ),
      data: (members) {
        if (members.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: 'No Members',
            subtitle: 'No team members found.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          itemCount: members.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) => MemberTile(member: members[index]),
        );
      },
    );
  }

  Widget _buildDepartmentsTab() {
    final departmentsAsync = ref.watch(departmentListProvider);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: 'Add Department',
            icon: Icons.add,
            isCompact: true,
            onPressed: () => _showCreateDepartmentDialog(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: departmentsAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => ErrorView(
              exception: e is AppException ? e : UnknownException(e.toString()),
              onRetry: () => ref.invalidate(departmentListProvider),
            ),
            data: (departments) {
              if (departments.isEmpty) {
                return EmptyState(
                  icon: Icons.business_outlined,
                  title: 'No Departments',
                  subtitle: 'Create your first department.',
                );
              }
              return ListView.separated(
                itemCount: departments.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    _buildDepartmentTile(departments[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentTile(Department dept) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (dept.description != null)
                  Text(
                    dept.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${dept.memberCount} members',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    final teamsAsync = ref.watch(teamListProvider);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: 'Add Team',
            icon: Icons.add,
            isCompact: true,
            onPressed: () => _showCreateTeamDialog(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: teamsAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => ErrorView(
              exception: e is AppException ? e : UnknownException(e.toString()),
              onRetry: () => ref.invalidate(teamListProvider),
            ),
            data: (teams) {
              if (teams.isEmpty) {
                return EmptyState(
                  icon: Icons.group_outlined,
                  title: 'No Teams',
                  subtitle: 'Create your first team.',
                );
              }
              return ListView.separated(
                itemCount: teams.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _buildTeamTile(teams[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamTile(TeamModel team) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.group_outlined,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (team.departmentName != null)
                  Text(
                    team.departmentName!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${team.memberCount} members',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab() {
    final rolesAsync = ref.watch(roleListProvider);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: 'Add Role',
            icon: Icons.add,
            isCompact: true,
            onPressed: () => _showCreateRoleDialog(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: rolesAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => ErrorView(
              exception: e is AppException ? e : UnknownException(e.toString()),
              onRetry: () => ref.invalidate(roleListProvider),
            ),
            data: (roles) {
              if (roles.isEmpty) {
                return EmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'No Roles',
                  subtitle: 'Create your first role.',
                );
              }
              return ListView.separated(
                itemCount: roles.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _buildRoleTile(roles[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTile(Role role) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (role.description != null)
                  Text(
                    role.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${role.memberCount} members',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDepartmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Create Department',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(hint: 'Department name', controller: nameController),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hint: 'Description (optional)',
                controller: descController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: 'Create',
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final dept = Department(
                id: '',
                orgId: '',
                name: name,
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await ref.read(createDepartmentProvider(dept).future);
              ref.invalidate(departmentListProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Create Team',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(hint: 'Team name', controller: nameController),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hint: 'Description (optional)',
                controller: descController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: 'Create',
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final team = TeamModel(
                id: '',
                orgId: '',
                name: name,
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await ref.read(createTeamProvider(team).future);
              ref.invalidate(teamListProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showCreateRoleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Create Role',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(hint: 'Role name', controller: nameController),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hint: 'Description (optional)',
                controller: descController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: 'Create',
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final role = Role(
                id: '',
                orgId: '',
                name: name,
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await ref.read(createRoleProvider(role).future);
              ref.invalidate(roleListProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
