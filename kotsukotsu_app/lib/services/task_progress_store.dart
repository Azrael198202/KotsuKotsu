import 'package:isar/isar.dart';

import '../models/navigation_args.dart';
import '../models/task_progress.dart';
import 'isar_service.dart';

class TaskProgressStore {
  static Future<void> recordResult(ResultArgs args) async {
    final isar = await IsarService.getInstance();
    final id = _progressId(args.grade, args.taskKey);
    final entity = TaskProgressEntity()
      ..id = id
      ..grade = args.grade
      ..taskKey = args.taskKey
      ..correct = args.correct
      ..total = args.total
      ..durationSeconds = args.durationSeconds
      ..passScore = args.passScore
      ..timeLimitSeconds = args.timeLimitSeconds
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.taskProgressEntitys.put(entity);
    });
  }

  static Future<Map<String, TaskProgressEntity>> getProgressForGrade(
    int grade,
    Iterable<String> taskKeys,
  ) async {
    final isar = await IsarService.getInstance();
    final ids = taskKeys.map((key) => _progressId(grade, key)).toList();
    if (ids.isEmpty) return <String, TaskProgressEntity>{};
    final list = await isar.taskProgressEntitys.getAll(ids);
    final map = <String, TaskProgressEntity>{};
    for (final item in list) {
      if (item == null) continue;
      map[item.taskKey] = item;
    }
    return map;
  }

  static int _progressId(int grade, String taskKey) {
    return _stableHash('g$grade/$taskKey');
  }

  static int _stableHash(String input) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
