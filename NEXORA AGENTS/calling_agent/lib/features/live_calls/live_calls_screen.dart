import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/filter_bar.dart';
import 'widgets/live_call_card.dart';
import 'widgets/live_transcript.dart';
import 'widgets/call_controls.dart';
import 'widgets/sentiment_meter.dart';

class LiveCallsScreen extends StatefulWidget {
  const LiveCallsScreen({super.key});

  @override
  State<LiveCallsScreen> createState() => _LiveCallsScreenState();
}

class _LiveCallsScreenState extends State<LiveCallsScreen> {
  String _filter = 'All';
  int? _expandedIndex;

  final _mockCalls = [
    {
      'name': 'John Smith',
      'number': '+1 (555) 123-4567',
      'duration': '3:24',
      'status': 'active',
      'agent': 'AI Agent',
      'sentiment': 0.82,
    },
    {
      'name': 'Sarah Johnson',
      'number': '+1 (555) 987-6543',
      'duration': '1:52',
      'status': 'ringing',
      'agent': 'Alice (Human)',
      'sentiment': 0.45,
    },
    {
      'name': 'Mike Brown',
      'number': '+1 (555) 456-7890',
      'duration': '5:10',
      'status': 'active',
      'agent': 'AI Agent',
      'sentiment': 0.28,
    },
    {
      'name': 'Emily Davis',
      'number': '+1 (555) 789-0123',
      'duration': '0:45',
      'status': 'holding',
      'agent': 'Bob (Human)',
      'sentiment': 0.65,
    },
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
                Text('Live Calls', style: AppTypography.displayMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.activeCall.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.activeCall,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_mockCalls.length} Active',
                        style: const TextStyle(
                          color: AppColors.activeCall,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FilterBar(
              searchHint: 'Search calls...',
              onSearch: (v) {},
              chips: [
                FilterChipOption(label: 'All', selected: _filter == 'All', onSelected: (_) => setState(() => _filter = 'All')),
                FilterChipOption(label: 'My Calls', selected: _filter == 'My Calls', onSelected: (_) => setState(() => _filter = 'My Calls')),
                FilterChipOption(label: 'Unattended', selected: _filter == 'Unattended', onSelected: (_) => setState(() => _filter = 'Unattended')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _expandedIndex != null
                ? _buildExpandedView()
                : _buildCallGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCallGrid() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _mockCalls.length,
      itemBuilder: (context, index) {
        final call = _mockCalls[index];
        return LiveCallCard(
          callerName: call['name'] as String,
          callerNumber: call['number'] as String,
          duration: call['duration'] as String,
          status: call['status'] as String,
          agent: call['agent'] as String,
          sentiment: call['sentiment'] as double,
          expanded: false,
          onTap: () => setState(() => _expandedIndex = index),
        );
      },
    );
  }

  Widget _buildExpandedView() {
    final call = _mockCalls[_expandedIndex!];
    final mockTranscript = [
      TranscriptLine(text: 'Hello, am I speaking with John Smith?', isAi: true, timestamp: DateTime.now()),
      TranscriptLine(text: 'Yes, this is John speaking.', isAi: false, timestamp: DateTime.now()),
      TranscriptLine(text: 'Hi John, I\'m calling from Nexora about your recent inquiry.', isAi: true, timestamp: DateTime.now()),
      TranscriptLine(text: 'Oh great, yes I was interested in your services.', isAi: false, timestamp: DateTime.now()),
      TranscriptLine(text: 'Excellent! I\'d love to tell you more about what we offer.', isAi: true, timestamp: DateTime.now()),
    ];
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: LiveTranscript(lines: mockTranscript),
        ),
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
            child: Column(
              children: [
                SentimentMeter(sentiment: call['sentiment'] as double),
                const SizedBox(height: 16),
                CallControls(
                  onHoldToggle: () {},
                  onTransfer: () {},
                  onConference: () {},
                  onEndCall: () => setState(() => _expandedIndex = null),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('AI Mode', style: AppTypography.titleMedium),
                          const Spacer(),
                          Switch(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Caller', call['name'] as String),
                      _buildDetailRow('Number', call['number'] as String),
                      _buildDetailRow('Duration', call['duration'] as String),
                      _buildDetailRow('Agent', call['agent'] as String),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).paddingOnly(left: 24);
  }
}

extension on Widget {
  Widget paddingOnly({double left = 0, double right = 0, double top = 0, double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
      child: this,
    );
  }
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
