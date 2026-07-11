import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/call.dart';
import '../../providers/calls_provider.dart';
import '../widgets/sentiment_badge.dart';

class CallDetailScreen extends ConsumerWidget {
  final String callId;

  const CallDetailScreen({super.key, required this.callId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callAsync = ref.watch(callDetailProvider(callId));

    return callAsync.when(
      data: (call) => Scaffold(
        appBar: AppBar(title: const Text('Call Details')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCallInfoCard(context, call),
              const SizedBox(height: AppSpacing.xl),
              _buildCallStats(context, call),
              const SizedBox(height: AppSpacing.xl),
              _buildRecordingSection(context, call),
              if (call.transcription != null &&
                  call.transcription!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _buildTranscriptionSection(context, call),
              ],
            ],
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildCallInfoCard(BuildContext context, VoiceCall call) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDirectionIcon(context, call),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          call.direction == CallDirection.inbound
                              ? call.callerNumber
                              : call.calleeNumber,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildDirectionBadge(context, call),
                        const SizedBox(width: AppSpacing.sm),
                        _buildStatusBadge(context, call),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Call ID: ${call.id}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              SentimentBadge(sentiment: call.sentiment),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildInfoItem(
                Icons.access_time,
                'Duration',
                _formatDuration(call.durationSeconds),
              ),
              const SizedBox(width: AppSpacing.xl),
              _buildInfoItem(
                Icons.calendar_today,
                'Started',
                call.startedAt != null
                    ? DateFormat('MMM d, yyyy h:mm a').format(call.startedAt!)
                    : 'N/A',
              ),
              const SizedBox(width: AppSpacing.xl),
              _buildInfoItem(
                Icons.event,
                'Ended',
                call.endedAt != null
                    ? DateFormat('MMM d, yyyy h:mm a').format(call.endedAt!)
                    : 'N/A',
              ),
              if (call.outcome != null) ...[
                const SizedBox(width: AppSpacing.xl),
                _buildOutcomeBadge(context, call),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionIcon(BuildContext context, VoiceCall call) {
    final isInbound = call.direction == CallDirection.inbound;
    final color = isInbound ? AppColors.success : AppColors.info;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isInbound ? Icons.call_received : Icons.call_made,
        size: 22,
        color: color,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionBadge(BuildContext context, VoiceCall call) {
    final isInbound = call.direction == CallDirection.inbound;
    final color = isInbound ? AppColors.success : AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isInbound ? 'Inbound' : 'Outbound',
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, VoiceCall call) {
    final (color, label) = switch (call.status) {
      CallStatus.queued => (AppColors.textTertiary, 'Queued'),
      CallStatus.ringing => (AppColors.warning, 'Ringing'),
      CallStatus.inProgress => (AppColors.success, 'In Progress'),
      CallStatus.completed => (AppColors.accent, 'Completed'),
      CallStatus.failed => (AppColors.error, 'Failed'),
      CallStatus.missed => (AppColors.error, 'Missed'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildOutcomeBadge(BuildContext context, VoiceCall call) {
    final (color, label) = switch (call.outcome) {
      CallOutcome.qualified => (AppColors.success, 'Qualified'),
      CallOutcome.appointmentBooked => (AppColors.accent, 'Appointment Booked'),
      CallOutcome.callbackRequested => (
        AppColors.warning,
        'Callback Requested',
      ),
      CallOutcome.noAnswer => (AppColors.error, 'No Answer'),
      CallOutcome.wrongNumber => (AppColors.error, 'Wrong Number'),
      null => (AppColors.textTertiary, 'Unknown'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(color: color),
      ),
    );
  }

  Widget _buildCallStats(BuildContext context, VoiceCall call) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Duration',
            _formatDuration(call.durationSeconds),
            Icons.timer_outlined,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _buildStatCard(
            context,
            'Status',
            call.status.name.toUpperCase().replaceAll('_', ' '),
            Icons.info_outline,
            _statusColor(call),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _buildStatCard(
            context,
            'Recording',
            call.recordingUrl != null ? 'Available' : 'None',
            Icons.mic_outlined,
            call.recordingUrl != null
                ? AppColors.success
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection(BuildContext context, VoiceCall call) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recording',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (call.recordingUrl != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 20,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Play Recording',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No recording available',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionSection(BuildContext context, VoiceCall call) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transcription',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                call.transcription!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(VoiceCall call) {
    return switch (call.status) {
      CallStatus.queued => AppColors.textTertiary,
      CallStatus.ringing => AppColors.warning,
      CallStatus.inProgress => AppColors.success,
      CallStatus.completed => AppColors.accent,
      CallStatus.failed => AppColors.error,
      CallStatus.missed => AppColors.error,
    };
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds.toString().padLeft(2, '0')}s';
  }
}
