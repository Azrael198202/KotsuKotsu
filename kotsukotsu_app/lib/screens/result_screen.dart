import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import 'grade_select_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const String routeName = '/result';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ResultArgs;
    final pass = args.isPassed;
    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pass ? '合格' : '不合格',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('得点：${args.correct}/${args.total}（合格点 ${args.passScore}）'),
            Text('時間：${args.durationSeconds}秒（制限 ${args.timeLimitSeconds}秒）'),
            const SizedBox(height: 24),
            if (!pass)
              FilledButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    QuizScreen.routeName,
                    arguments: TaskArgs(
                      grade: args.grade,
                      taskKey: args.taskKey,
                      taskName: args.taskName,
                    ),
                  );
                },
                child: const Text('もう一度挑戦'),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  GradeSelectScreen.routeName,
                  (route) => false,
                );
              },
              child: const Text('学年選択に戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
