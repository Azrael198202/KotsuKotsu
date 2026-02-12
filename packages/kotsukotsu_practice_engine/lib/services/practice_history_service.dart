import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/navigation_args.dart';

class PracticeAttempt {
  const PracticeAttempt({
    required this.grade,
    required this.taskKey,
    required this.taskName,
    required this.total,
    required this.correct,
    required this.durationSeconds,
    required this.timestamp,
  });

  final int grade;
  final String taskKey;
  final String taskName;
  final int total;
  final int correct;
  final int durationSeconds;
  final DateTime timestamp;

  double get errorRate => total <= 0 ? 0 : (total - correct) / total;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'grade': grade,
      'taskKey': taskKey,
      'taskName': taskName,
      'total': total,
      'correct': correct,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PracticeAttempt.fromJson(Map<String, dynamic> json) {
    return PracticeAttempt(
      grade: json['grade'] as int? ?? 0,
      taskKey: json['taskKey'] as String? ?? '',
      taskName: json['taskName'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PracticeHistoryService {
  static const String _historyKey = 'kk_practice_history';
  static const int _maxEntries = 500;

  static Future<void> record(ResultArgs args) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadAll();
    list.add(
      PracticeAttempt(
        grade: args.grade,
        taskKey: args.taskKey,
        taskName: args.taskName,
        total: args.total,
        correct: args.correct,
        durationSeconds: args.durationSeconds,
        timestamp: DateTime.now(),
      ),
    );
    final trimmed =
        list.length <= _maxEntries ? list : list.sublist(list.length - _maxEntries);
    final encoded = trimmed.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  static Future<List<PracticeAttempt>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? const <String>[];
    final result = <PracticeAttempt>[];
    for (final item in raw) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        result.add(PracticeAttempt.fromJson(decoded));
      } catch (_) {}
    }
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }
}
