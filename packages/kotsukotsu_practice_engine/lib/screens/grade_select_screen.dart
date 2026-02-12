import 'package:flutter/material.dart';

import '../config/app_engine_config.dart';
import '../config/app_navigation_config.dart';
import '../models/navigation_args.dart';
import '../services/assignment_rules_loader.dart';
import '../services/question_bank_loader.dart';
import 'membership_screen.dart';
import 'overview_screen.dart';
import 'task_select_screen.dart';

class GradeSelectScreen extends StatefulWidget {
  const GradeSelectScreen({super.key});

  static const String routeName = '/';

  @override
  State<GradeSelectScreen> createState() => _GradeSelectScreenState();
}

class _GradeSelectScreenState extends State<GradeSelectScreen> {
  late final Future<List<int>> _gradesFuture;
  final _rulesLoader = AssignmentRulesLoader(
    assetPath: appEngineConfig.assignmentRulesAssetPath,
  );
  final _bankLoader = QuestionBankLoader(
    assetBasePath: appEngineConfig.questionBankBasePath,
    useGradeSubdirectory: appEngineConfig.useGradeSubdirectory,
  );

  @override
  void initState() {
    super.initState();
    _gradesFuture = _loadAvailableGrades();
  }

  Future<List<int>> _loadAvailableGrades() async {
    final ruleGrades = <int>{};
    try {
      final configs = await _rulesLoader.loadConfigs();
      for (final config in configs) {
        ruleGrades.add(config.grade);
      }
    } catch (_) {}

    var assetGrades = const <int>[];
    try {
      assetGrades = await _bankLoader.availableGrades();
    } catch (_) {}

    if (ruleGrades.isEmpty && assetGrades.isEmpty) {
      return List<int>.generate(6, (index) => index + 1);
    }
    if (ruleGrades.isEmpty) return assetGrades;
    if (assetGrades.isEmpty) {
      final grades = ruleGrades.toList()..sort();
      return grades;
    }
    final intersected = assetGrades.where(ruleGrades.contains).toList()..sort();
    if (intersected.isNotEmpty) return intersected;
    return assetGrades;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('年級選択'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, OverviewScreen.routeName),
            icon: const Icon(Icons.analytics),
            tooltip: '総覧',
          ),
          if (AppNavigationScope.of(context).enableMembership)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, MembershipScreen.routeName),
              icon: const Icon(Icons.workspace_premium),
              tooltip: '会員ページ',
            ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: _gradesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final grades = snapshot.data ?? const <int>[];
          if (grades.isEmpty) {
            return const Center(child: Text('年級データが見つかりません。'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grades.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final grade = grades[index];
              return FilledButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    TaskSelectScreen.routeName,
                    arguments: GradeArgs(grade: grade),
                  );
                },
                child: Text('Grade $grade'),
              );
            },
          );
        },
      ),
    );
  }
}
