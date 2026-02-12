class AssignmentConfig {
  AssignmentConfig({
    required this.grade,
    required this.taskKey,
    required this.taskName,
    required this.passScore,
    required this.timeLimitSeconds,
  });

  final int grade;
  final String taskKey;
  final String taskName;
  final int passScore;
  final int timeLimitSeconds;

  factory AssignmentConfig.fromJson(
    int grade,
    String taskKey,
    Map<String, dynamic> json,
  ) {
    return AssignmentConfig(
      grade: grade,
      taskKey: taskKey,
      taskName: json['name'] as String? ?? taskKey,
      passScore: json['passScore'] as int? ?? 0,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 0,
    );
  }
}
