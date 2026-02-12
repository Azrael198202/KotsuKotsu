import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import '../services/app_user_service.dart';
import 'login_screen.dart';
import 'task_select_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  static const String routeName = '/intro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アプリ紹介')),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Text(
                  'KotsuKotsuへようこそ。\n\n'
                  'このアプリは小学生向けの算数練習アプリです。\n'
                  '- オフラインで利用可能\n'
                  '- 年級別の課題\n'
                  '- 学習記録の保存\n'
                  '- 会員機能で学習進捗分析\n\n'
                  'まずはログインして学習を開始してください。',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final loggedIn = await AppUserService.isLoggedIn();
                    if (!context.mounted) return;
                    if (loggedIn) {
                      Navigator.pushReplacementNamed(
                        context,
                        TaskSelectScreen.routeName,
                        arguments: const GradeArgs(grade: 1),
                      );
                      return;
                    }
                    Navigator.pushReplacementNamed(
                      context,
                      LoginScreen.routeName,
                      arguments: const LoginArgs(grade: 1),
                    );
                  },
                  child: const Text('次へ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
