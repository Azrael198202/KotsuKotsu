class GradeArgs {
  const GradeArgs({required this.grade});

  final int grade;
}

class TaskArgs {
  const TaskArgs({
    required this.grade,
    required this.taskKey,
    required this.taskName,
  });

  final int grade;
  final String taskKey;
  final String taskName;
}

class ResultArgs {
  const ResultArgs({
    required this.grade,
    required this.taskKey,
    required this.taskName,
    required this.total,
    required this.correct,
    required this.durationSeconds,
    required this.passScore,
    required this.timeLimitSeconds,
  });

  final int grade;
  final String taskKey;
  final String taskName;
  final int total;
  final int correct;
  final int durationSeconds;
  final int passScore;
  final int timeLimitSeconds;

  bool get isPassed =>
      correct >= passScore && durationSeconds <= timeLimitSeconds;
}
