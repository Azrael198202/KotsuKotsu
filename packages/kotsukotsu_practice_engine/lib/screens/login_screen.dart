import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import '../services/app_user_service.dart';
import 'task_select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;
  String? _error;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final grade = args is LoginArgs ? args.grade : 1;

    return Scaffold(
      appBar: AppBar(title: Text(_registerMode ? '登録' : 'ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'ユーザーID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード'),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _submit(grade),
                child: Text(_registerMode ? '登録して開始' : 'ログインして開始'),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _registerMode = !_registerMode;
                  _error = null;
                });
              },
              child: Text(
                _registerMode ? 'すでにアカウントを持っている' : '新規登録へ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(int grade) async {
    setState(() => _error = null);
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    if (id.isEmpty || password.isEmpty) {
      setState(() => _error = 'IDとパスワードを入力してください');
      return;
    }
    final ok = _registerMode
        ? await AppUserService.register(loginId: id, password: password)
        : await AppUserService.login(loginId: id, password: password);
    if (!ok) {
      setState(() {
        _error = _registerMode ? '登録失敗: 既存IDの可能性があります' : 'ログイン失敗';
      });
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      TaskSelectScreen.routeName,
      arguments: GradeArgs(grade: grade),
    );
  }
}
