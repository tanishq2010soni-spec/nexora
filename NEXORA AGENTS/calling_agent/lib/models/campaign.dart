class Campaign {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? scriptId;
  final String? scriptName;
  final int totalLeads;
  final int answeredCalls;
  final int convertedCalls;
  final double cost;
  final String? scheduleConfig;
  final String? targetFilter;
  final DateTime createdAt;
  final DateTime? nextSchedule;
  final String? notes;

  const Campaign({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.scriptId,
    this.scriptName,
    this.totalLeads = 0,
    this.answeredCalls = 0,
    this.convertedCalls = 0,
    this.cost = 0,
    this.scheduleConfig,
    this.targetFilter,
    required this.createdAt,
    this.nextSchedule,
    this.notes,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      scriptId: json['script_id'] as String?,
      scriptName: json['script_name'] as String?,
      totalLeads: json['total_leads'] as int? ?? 0,
      answeredCalls: json['answered_calls'] as int? ?? 0,
      convertedCalls: json['converted_calls'] as int? ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      scheduleConfig: json['schedule_config'] as String?,
      targetFilter: json['target_filter'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      nextSchedule: json['next_schedule'] != null
          ? DateTime.parse(json['next_schedule'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'script_id': scriptId,
      'script_name': scriptName,
      'total_leads': totalLeads,
      'answered_calls': answeredCalls,
      'converted_calls': convertedCalls,
      'cost': cost,
      'schedule_config': scheduleConfig,
      'target_filter': targetFilter,
      'created_at': createdAt.toIso8601String(),
      'next_schedule': nextSchedule?.toIso8601String(),
      'notes': notes,
    };
  }
}
