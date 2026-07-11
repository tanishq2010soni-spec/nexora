class AnalyticsOverview {
  final int activeConversations;
  final int newLeadsToday;
  final double averageResponseTime;
  final double customerSatisfaction;
  final int messagesSent;
  final int messagesReceived;
  final int totalLeads;
  final int convertedLeads;
  final double totalRevenue;

  AnalyticsOverview({
    this.activeConversations = 0,
    this.newLeadsToday = 0,
    this.averageResponseTime = 0,
    this.customerSatisfaction = 0,
    this.messagesSent = 0,
    this.messagesReceived = 0,
    this.totalLeads = 0,
    this.convertedLeads = 0,
    this.totalRevenue = 0,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      activeConversations: json['active_conversations'] as int? ?? 0,
      newLeadsToday: json['new_leads_today'] as int? ?? 0,
      averageResponseTime:
          (json['average_response_time'] as num?)?.toDouble() ?? 0,
      customerSatisfaction:
          (json['customer_satisfaction'] as num?)?.toDouble() ?? 0,
      messagesSent: json['messages_sent'] as int? ?? 0,
      messagesReceived: json['messages_received'] as int? ?? 0,
      totalLeads: json['total_leads'] as int? ?? 0,
      convertedLeads: json['converted_leads'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_conversations': activeConversations,
      'new_leads_today': newLeadsToday,
      'average_response_time': averageResponseTime,
      'customer_satisfaction': customerSatisfaction,
      'messages_sent': messagesSent,
      'messages_received': messagesReceived,
      'total_leads': totalLeads,
      'converted_leads': convertedLeads,
      'total_revenue': totalRevenue,
    };
  }
}

class MetricPoint {
  final DateTime date;
  final double value;

  MetricPoint({required this.date, required this.value});

  factory MetricPoint.fromJson(Map<String, dynamic> json) {
    return MetricPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

class ConversationTrend {
  final List<MetricPoint> points;

  const ConversationTrend({this.points = const []});

  factory ConversationTrend.fromJson(Map<String, dynamic> json) {
    return ConversationTrend(
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => MetricPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class FunnelStage {
  final String label;
  final int count;
  final double conversionRate;

  FunnelStage({
    required this.label,
    required this.count,
    this.conversionRate = 0,
  });

  factory FunnelStage.fromJson(Map<String, dynamic> json) {
    return FunnelStage(
      label: json['label'] as String,
      count: json['count'] as int,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MetricsResponse {
  final ConversationTrend conversationTrend;
  final List<FunnelStage> leadFunnel;
  final List<MetricPoint> responseTimeDistribution;
  final Map<String, double> modelUsage;

  MetricsResponse({
    this.conversationTrend = const ConversationTrend(),
    this.leadFunnel = const [],
    this.responseTimeDistribution = const [],
    this.modelUsage = const {},
  });

  factory MetricsResponse.fromJson(Map<String, dynamic> json) {
    return MetricsResponse(
      conversationTrend: json['conversation_trend'] != null
          ? ConversationTrend.fromJson(json['conversation_trend'] as Map<String, dynamic>)
          : ConversationTrend(),
      leadFunnel: (json['lead_funnel'] as List<dynamic>?)
              ?.map((e) => FunnelStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      responseTimeDistribution: (json['response_time_distribution'] as List<dynamic>?)
              ?.map((e) => MetricPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      modelUsage: (json['model_usage'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          const {},
    );
  }
}

class RevenueAttribution {
  final String source;
  final double revenue;
  final int conversions;

  RevenueAttribution({
    required this.source,
    required this.revenue,
    this.conversions = 0,
  });

  factory RevenueAttribution.fromJson(Map<String, dynamic> json) {
    return RevenueAttribution(
      source: json['source'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      conversions: json['conversions'] as int? ?? 0,
    );
  }
}
