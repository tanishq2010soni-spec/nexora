import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text('Permissions', style: AppTypography.displayMedium),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Roles'),
                      Tab(text: 'Permissions'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRolesTab(),
                        _buildPermissionsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) {
        final roles = [
          {'name': 'Admin', 'users': '3', 'perms': 'All'},
          {'name': 'Supervisor', 'users': '5', 'perms': 'Monitor, Listen, Coach'},
          {'name': 'Agent', 'users': '12', 'perms': 'Call, View Leads'},
          {'name': 'Viewer', 'users': '8', 'perms': 'View Analytics Only'},
        ];
        final r = roles[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(r['name']![0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name']!, style: AppTypography.titleMedium),
                    Text('${r['users']} users | ${r['perms']}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary), onPressed: () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Permission Matrix', style: AppTypography.titleMedium),
              const Spacer(),
              AppButton(label: 'Add Permission', icon: Icons.add, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
                columns: const [
                  DataColumn(label: Text('Resource', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Admin', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Supervisor', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Agent', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Viewer', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                ],
                rows: [
                  ['Calls', '✓', '✓', '✓', '—'],
                  ['Leads', '✓', '✓', '✓', '—'],
                  ['Campaigns', '✓', '✓', '—', '—'],
                  ['Settings', '✓', '—', '—', '—'],
                  ['Analytics', '✓', '✓', '✓', '✓'],
                  ['Users', '✓', '—', '—', '—'],
                ].map((r) => DataRow(cells: r.map((c) => DataCell(Text(c, style: TextStyle(color: c == '✓' ? AppColors.success : AppColors.textMuted, fontWeight: c == '✓' ? FontWeight.w600 : FontWeight.normal)))).toList())).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
