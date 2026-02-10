import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task_progress.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    final existing = _isar;
    if (existing != null) {
      return existing;
    }
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [TaskProgressEntitySchema],
      directory: dir.path,
    );
    _isar = isar;
    return isar;
  }
}
