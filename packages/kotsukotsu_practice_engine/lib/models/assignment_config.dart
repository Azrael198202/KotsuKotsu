class AssignmentConfig {
  AssignmentConfig({
    required this.grade,
    required this.taskKey,
    required this.taskName,
    required this.passScore,
    required this.timeLimitSeconds,
    this.firstTierScore,
    this.secondTierScore,
    this.thirdTierScore,
  });

  final int grade;
  final String taskKey;
  final String taskName;
  final int passScore;
  final int timeLimitSeconds;
  final int? firstTierScore;
  final int? secondTierScore;
  final int? thirdTierScore;

  bool get isTestTask => taskKey.toLowerCase().contains('test');

  String? medalAssetFor({
    required int score,
    required bool isPassed,
  }) {
    if (!isTestTask || !isPassed) return null;
    if (firstTierScore != null && score >= firstTierScore!) {
      return 'assets/bg/gold.png';
    }
    if (secondTierScore != null && score >= secondTierScore!) {
      return 'assets/bg/silver.png';
    }
    if (thirdTierScore != null && score >= thirdTierScore!) {
      return 'assets/bg/copper.png';
    }
    return null;
  }

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
      firstTierScore: json['firstTierScore'] as int?,
      secondTierScore: json['secondTierScore'] as int?,
      thirdTierScore: json['thirdTierScore'] as int?,
    );
  }
}
