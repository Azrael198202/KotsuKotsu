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
    required this.reviews,
  });

  final int grade;
  final String taskKey;
  final String taskName;
  final int total;
  final int correct;
  final int durationSeconds;
  final int passScore;
  final int timeLimitSeconds;
  final List<ReviewItem> reviews;

  bool get isPassed =>
      correct >= passScore &&
      (timeLimitSeconds <= 0 || durationSeconds <= timeLimitSeconds);
}

class ReviewItem {
  const ReviewItem({
    required this.raw,
    required this.type,
    required this.expected,
    required this.input,
  });

  final String raw;
  final String type;
  final String expected;
  final String input;
}

class PaymentArgs {
  const PaymentArgs({
    required this.grade,
    this.taskName,
  });

  final int grade;
  final String? taskName;
}

class LoginArgs {
  const LoginArgs({
    required this.grade,
  });

  final int grade;
}
