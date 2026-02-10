import 'package:flutter/material.dart';

import 'models/navigation_args.dart';
import 'screens/grade_select_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/task_select_screen.dart';

class KotsuKotsuApp extends StatelessWidget {
  const KotsuKotsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KotsuKotsu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      initialRoute: GradeSelectScreen.routeName,
      routes: {
        GradeSelectScreen.routeName: (_) => const GradeSelectScreen(),
        TaskSelectScreen.routeName: (_) => const TaskSelectScreen(),
        QuizScreen.routeName: (_) => const QuizScreen(),
        ResultScreen.routeName: (_) => const ResultScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == TaskSelectScreen.routeName &&
            settings.arguments is GradeArgs) {
          return MaterialPageRoute(
            builder: (_) => const TaskSelectScreen(),
            settings: settings,
          );
        }
        if (settings.name == QuizScreen.routeName &&
            settings.arguments is TaskArgs) {
          return MaterialPageRoute(
            builder: (_) => const QuizScreen(),
            settings: settings,
          );
        }
        if (settings.name == ResultScreen.routeName &&
            settings.arguments is ResultArgs) {
          return MaterialPageRoute(
            builder: (_) => const ResultScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
