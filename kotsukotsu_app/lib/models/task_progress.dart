import 'package:isar/isar.dart';

part 'task_progress.g.dart';

@collection
class TaskProgressEntity {
  TaskProgressEntity();

  Id id = Isar.autoIncrement;

  late int grade;
  late String taskKey;
  late int correct;
  late int total;
  late int durationSeconds;
  late int passScore;
  late int timeLimitSeconds;
  late DateTime updatedAt;

  bool get isPassed =>
      correct >= passScore && durationSeconds <= timeLimitSeconds;

  bool get isPerfect => total > 0 && correct == total;

  String get scoreLabel => total > 0 ? '$correct/$total' : '$correct';
}
