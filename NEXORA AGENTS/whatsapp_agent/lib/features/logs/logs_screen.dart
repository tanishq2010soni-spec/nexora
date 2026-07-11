import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/filter_bar.dart';
import '../../providers/log_provider.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  int? _expandedLogId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogProvider>().loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Audit Logs', style: AppTypography.displaySmall),
                const SizedBox(height: 4),
                Text('Track all activities and changes', style: AppTypography.bodyMedium),
              ],
            ),
          ),
          FilterBar(
            searchHint: 'Search by user...',
            onSearchChanged: (q) => provider.setUserFilter(q),
            dropdowns: [
              FilterDropdown(
                label: 'Action',
                value: '',
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Actions')),
                  DropdownMenuItem(value: 'create', child: Text('Create')),
                  DropdownMenuItem(value: 'update', child: Text('Update')),
                  DropdownMenuItem(value: 'delete', child: Text('Delete')),
                  DropdownMenuItem(value: 'login', child: Text('Login')),
                  DropdownMenuItem(value: 'send_message', child: Text('Send Message')),
                ],
                onChanged: (v) => provider.setActionFilter(v ?? ''),
              ),
              FilterDropdown(
                label: 'Resource',
                value: '',
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Resources')),
                  DropdownMenuItem(value: 'conversation', child: Text('Conversation')),
                  DropdownMenuItem(value: 'lead', child: Text('Lead')),
                  DropdownMenuItem(value: 'workflow', child: Text('Workflow')),
                  DropdownMenuItem(value: 'campaign', child: Text('Campaign')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (v) => provider.setResourceFilter(v ?? ''),
              ),
            ],
            onDateRangeTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (range != null) {
                provider.setDateRange(range.start, range.end);
              }
            },
            onClear: () => provider.clearFilters(),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.logs.isEmpty
                    ? Center(child: Text('No audit logs found', style: AppTypography.bodyMedium))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.logs.length,
                        itemBuilder: (context, index) {
                          final log = provider.logs[index];
                          final isExpanded = _expandedLogId == log.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () => setState(() => _expandedLogId = isExpanded ? null : log.id),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          log.action == 'create' ? Icons.add_circle_outline_rounded :
                                          log.action == 'update' ? Icons.edit_rounded :
                                          log.action == 'delete' ? Icons.delete_outline_rounded :
                                          Icons.info_outline_rounded,
                                          size: 18,
                                          color: log.action == 'create' ? AppColors.success :
                                                 log.action == 'delete' ? AppColors.error :
                                                 AppColors.info,
                                        ),
                                        const SizedBox(width: 12),
                                        _badge(log.actionLabel, log.action == 'create' ? AppColors.success : log.action == 'delete' ? AppColors.error : AppColors.info),
                                        const SizedBox(width: 12),
                                        Expanded(flex: 2, child: Text(log.userName ?? 'System', style: AppTypography.titleMedium)),
                                        Expanded(flex: 2, child: Text(log.resourceType, style: AppTypography.bodyMedium)),
                                        Expanded(flex: 1, child: Text(log.resourceId?.toString() ?? '-', style: AppTypography.bodySmall)),
                                        Expanded(flex: 2, child: Text(log.createdAt.toString().split('.')[0], style: AppTypography.bodySmall)),
                                        Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: AppColors.textMuted),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isExpanded && log.details != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.inputBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        const JsonEncoder.withIndent('  ').convert(log.details),
                                        style: AppTypography.code.copyWith(fontSize: 11),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
