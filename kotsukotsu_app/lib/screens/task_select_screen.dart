import 'package:flutter/material.dart';

import '../models/assignment_config.dart';
import '../models/navigation_args.dart';
import '../services/assignment_rules_loader.dart';
import 'quiz_screen.dart';

class TaskSelectScreen extends StatefulWidget {
  const TaskSelectScreen({super.key});

  static const String routeName = '/tasks';

  @override
  State<TaskSelectScreen> createState() => _TaskSelectScreenState();
}

class _TaskSelectScreenState extends State<TaskSelectScreen> {
  final _rulesLoader = AssignmentRulesLoader();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GradeArgs;
    return Scaffold(
      appBar: AppBar(title: Text('課題タイプ（小学${args.grade}年）')),
      body: FutureBuilder<List<AssignmentConfig>>(
        future: _rulesLoader.loadConfigsForGrade(args.grade),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final configs = snapshot.data ?? [];
          if (configs.isEmpty) {
            return const Center(child: Text('この学年は課題が未設定です'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: configs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final config = configs[index];
              return ListTile(
                title: Text(config.taskName),
                subtitle: Text('合格点：${config.passScore}、制限時間：${config.timeLimitSeconds}秒'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    QuizScreen.routeName,
                    arguments: TaskArgs(
                      grade: config.grade,
                      taskKey: config.taskKey,
                      taskName: config.taskName,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
