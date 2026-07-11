import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/agent_status_card.dart';
import 'widgets/whisper_input.dart';
import 'widgets/coaching_panel.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  int? _selectedCall;

  final _mockActiveCalls = [
    {'name': 'John Smith', 'number': '+1 (555) 123-4567', 'agent': 'AI Agent', 'duration': '3:24', 'sentiment': 0.82},
    {'name': 'Sarah Johnson', 'number': '+1 (555) 987-6543', 'agent': 'Alice (Human)', 'duration': '1:52', 'sentiment': 0.45},
    {'name': 'Mike Brown', 'number': '+1 (555) 456-7890', 'agent': 'AI Agent', 'duration': '5:10', 'sentiment': 0.28},
  ];

  final _mockAgents = [
    {'name': 'AI Agent', 'status': 'On-Call', 'calls': '342', 'sentiment': 0.74},
    {'name': 'Alice', 'status': 'On-Call', 'calls': '156', 'sentiment': 0.65},
    {'name': 'Bob', 'status': 'Available', 'calls': '98', 'sentiment': 0.0},
    {'name': 'Carol', 'status': 'Break', 'calls': '45', 'sentiment': 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Text('Supervisor Monitor', style: AppTypography.displayMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.activeCall.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.activeCall),
                      SizedBox(width: 8),
                      Text('3 Active Calls', style: TextStyle(color: AppColors.activeCall, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
                    child: _selectedCall != null ? _buildCallDetail() : _buildCallList(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
                    child: _buildAgentPanel(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallList() {
    return ListView.builder(
      itemCount: _mockActiveCalls.length,
      itemBuilder: (_, i) {
        final c = _mockActiveCalls[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () => setState(() => _selectedCall = i),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.activeCall.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone_in_talk, color: AppColors.activeCall, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['name'] as String, style: AppTypography.titleMedium),
                      Text('${c['number']!} | ${c['agent']}', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(c['duration'] as String, style: AppTypography.bodyMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (c['sentiment'] as double) >= 0.6
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((c['sentiment'] as double) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: (c['sentiment'] as double) >= 0.6 ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallDetail() {
    final c = _mockActiveCalls[_selectedCall!];
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedCall = null),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(c['name'] as String, style: AppTypography.headlineMedium)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.activeCall, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Live Transcript', style: AppTypography.titleMedium),
                    const Spacer(),
                    Text('Streaming...', style: AppTypography.caption),
                  ],
                ),
                const Divider(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _transcriptLine('AI', 'Hello, am I speaking with John?'),
                      _transcriptLine('Human', 'Yes, this is John.'),
                      _transcriptLine('AI', 'Hi John, I\'m calling from Nexora...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text('Sentiment', style: AppTypography.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                        '${((c['sentiment'] as double) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: (c['sentiment'] as double) >= 0.6 ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WhisperInput(onSend: (_) {}),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CoachingPanel(
            suggestions: const [
              'Remind agent to ask open-ended questions',
              'Suggest mentioning the current promotion',
              'Customer seems interested - push for close',
            ],
            onBargeIn: () {},
          ),
        ],
      ),
    );
  }

  Widget _transcriptLine(String speaker, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: speaker == 'AI' ? AppColors.primary.withValues(alpha: 0.2) : AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(speaker, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: speaker == 'AI' ? AppColors.primary : AppColors.secondary)),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildAgentPanel() {
    return Column(
      children: [
        Row(
          children: [
            Text('Agent Status', style: AppTypography.titleMedium),
            const Spacer(),
            Text('${_mockAgents.length} agents', style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_mockAgents.length, (i) {
          final a = _mockAgents[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AgentStatusCard(
              name: a['name'] as String,
              status: a['status'] as String,
              callsToday: int.parse(a['calls'] as String),
              avgSentiment: (a['sentiment'] as double),
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Queue Overview', style: AppTypography.titleMedium),
              const SizedBox(height: 8),
              _queueStat('Calls Waiting', '4'),
              _queueStat('Longest Wait', '2:15'),
              _queueStat('Avg Wait', '1:36'),
              _queueStat('Agents Available', '2'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _queueStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodySmall),
          const Spacer(),
          Text(value, style: AppTypography.titleMedium),
        ],
      ),
    );
  }
}
