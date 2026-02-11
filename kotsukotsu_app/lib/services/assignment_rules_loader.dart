import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/assignment_config.dart';

class AssignmentRulesLoader {
  AssignmentRulesLoader({
    this.assetPath = 'assets/assignments/rules.json',
  });

  final String assetPath;

  Future<List<AssignmentConfig>> loadConfigs() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final configs = <AssignmentConfig>[];

    for (final entry in decoded.entries) {
      final grade = int.tryParse(entry.key.replaceAll('g', '')) ?? 0;
      final tasks = entry.value as Map<String, dynamic>;
      for (final taskEntry in tasks.entries) {
        configs.add(
          AssignmentConfig.fromJson(
            grade,
            taskEntry.key,
            taskEntry.value as Map<String, dynamic>,
          ),
        );
      }
    }
    return configs;
  }

  Future<List<AssignmentConfig>> loadConfigsForGrade(int grade) async {
    final configs = await loadConfigs();
    return configs.where((config) => config.grade == grade).toList();
  }
}
