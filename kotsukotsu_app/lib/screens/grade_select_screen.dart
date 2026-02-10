import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import 'task_select_screen.dart';

class GradeSelectScreen extends StatelessWidget {
  const GradeSelectScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    final grades = List<int>.generate(6, (index) => index + 1);
    return Scaffold(
      appBar: AppBar(title: const Text('学年を選択')),
      body: ListView.separated(
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
            child: Text('小学${grade}年'),
          );
        },
      ),
    );
  }
}
