enum StepType {
  agentCall,
  toolExecution,
  condition,
  transformation,
  notification,
  webhook,
  delay,
  subWorkflow,
  custom;

  String toJson() => name;

  static StepType fromJson(String json) {
    return StepType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => StepType.custom,
    );
  }
}
