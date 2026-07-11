import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/contact_detail_panel.dart';
import 'widgets/appointment_form.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedContact;

  final _mockContacts = [
    {'name': 'Alice Williams', 'phone': '+1 (555) 111-2233', 'email': 'alice@acme.com', 'company': 'Acme Corp', 'calls': '12', 'last': '2 days ago', 'title': 'CEO', 'notes': 'Key decision maker'},
    {'name': 'Bob Davis', 'phone': '+1 (555) 222-3344', 'email': 'bob@techco.com', 'company': 'TechCo', 'calls': '8', 'last': '1 week ago', 'title': 'CTO', 'notes': 'Interested in API integration'},
    {'name': 'Carol White', 'phone': '+1 (555) 333-4455', 'email': 'carol@datasys.com', 'company': 'DataSys', 'calls': '5', 'last': '3 days ago', 'title': 'VP Sales', 'notes': ''},
  ];

  final _mockAppointments = [
    {'title': 'Demo Call', 'contact': 'Alice Williams', 'date': '2026-07-01 10:00', 'status': 'Scheduled', 'assigned': 'AI Agent'},
    {'title': 'Follow-up Meeting', 'contact': 'Bob Davis', 'date': '2026-07-02 14:00', 'status': 'Scheduled', 'assigned': 'Alice'},
    {'title': 'Contract Review', 'contact': 'Carol White', 'date': '2026-06-28 11:00', 'status': 'Completed', 'assigned': 'Bob'},
  ];

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('CRM', style: AppTypography.displayMedium),
                const Spacer(),
                AppButton(label: 'Add Contact', icon: Icons.person_add, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            Container(
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
                      Tab(text: 'Contacts'),
                      Tab(text: 'Appointments'),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildContactsTab(),
                        _buildAppointmentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsTab() {
    if (_selectedContact != null) {
      return _buildContactDetail();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockContacts.length,
      itemBuilder: (_, i) {
        final c = _mockContacts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () => setState(() => _selectedContact = i),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(c['name']![0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name']!, style: AppTypography.titleMedium),
                        Text(c['phone']!, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${c['calls']} calls', style: AppTypography.bodySmall),
                      Text(c['last']!, style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactDetail() {
    final c = _mockContacts[_selectedContact!];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ContactDetailPanel(
            contact: c,
            onEdit: () {},
            onCall: () {},
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedContact = null),
              ),
              const SizedBox(width: 8),
              Text('Call History', style: AppTypography.titleMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockAppointments.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Spacer(),
                AppButton(label: 'New Appointment', icon: Icons.add, onPressed: () {
                  showDialog(context: context, builder: (_) => AppointmentForm(onSave: (_) {}));
                }),
              ],
            ),
          );
        }
        final a = _mockAppointments[i - 1];
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event, color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['title']!, style: AppTypography.titleMedium),
                    Text('${a['contact']} | ${a['date']}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: a['status'] == 'Completed' ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(a['status']!, style: TextStyle(fontSize: 11, color: a['status'] == 'Completed' ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }
}
