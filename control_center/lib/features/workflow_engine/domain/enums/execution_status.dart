enum ExecutionStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
  paused;

  String toJson() => name;

  static ExecutionStatus fromJson(String json) {
    return ExecutionStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ExecutionStatus.pending,
    );
  }
}
