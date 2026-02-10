import 'dart:async';

import 'package:flutter/material.dart';

import '../models/assignment_config.dart';
import '../models/navigation_args.dart';
import '../models/question.dart';
import '../services/assignment_rules_loader.dart';
import '../services/question_bank_loader.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  static const String routeName = '/quiz';

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _rulesLoader = AssignmentRulesLoader();
  final _bankLoader = QuestionBankLoader();
  final _controllers = <TextEditingController>[];
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TaskArgs;
    return Scaffold(
      appBar: AppBar(title: Text(args.taskName)),
      body: FutureBuilder<_QuizData>(
        future: _loadData(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.questions.isEmpty) {
            return const Center(child: Text('問題が見つかりません'));
          }
          _ensureControllers(data.questions.length);
          _startTimerIfNeeded();
          return Column(
            children: [
              _buildHeader(data.config),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.questions.length,
                  itemBuilder: (context, index) {
                    final question = data.questions[index];
                    return _buildQuestionTile(question, index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => _submit(args, data),
                  child: const Text('提出する'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AssignmentConfig config) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('制限時間：${config.timeLimitSeconds}秒'),
          Text('合格点：${config.passScore}'),
          Text('経過：${_elapsedSeconds}秒'),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(Question question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('第${index + 1}問：${question.raw}'),
            const SizedBox(height: 8),
            TextField(
              controller: _controllers[index],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '答えを入力',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_QuizData> _loadData(TaskArgs args) async {
    final configs = await _rulesLoader.loadConfigsForGrade(args.grade);
    final config = configs.firstWhere(
      (item) => item.taskKey == args.taskKey,
      orElse: () => AssignmentConfig(
        grade: args.grade,
        taskKey: args.taskKey,
        taskName: args.taskName,
        passScore: 0,
        timeLimitSeconds: 0,
      ),
    );
    final questions = await _bankLoader.loadQuestions(
      grade: args.grade,
      taskKey: args.taskKey,
    );
    return _QuizData(config: config, questions: questions);
  }

  void _ensureControllers(int count) {
    if (_controllers.length == count) return;
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers
      ..clear()
      ..addAll(List.generate(count, (_) => TextEditingController()));
  }

  void _startTimerIfNeeded() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds = _stopwatch.elapsed.inSeconds;
      });
    });
  }

  void _submit(TaskArgs args, _QuizData data) {
    _stopwatch.stop();
    _timer?.cancel();

    var correct = 0;
    for (var i = 0; i < data.questions.length; i++) {
      final expected = data.questions[i].expectedAnswer;
      final input = _controllers[i].text.trim();
      if (expected != null && expected.isNotEmpty && input == expected) {
        correct++;
      }
    }
    final result = ResultArgs(
      grade: args.grade,
      taskKey: args.taskKey,
      taskName: args.taskName,
      total: data.questions.length,
      correct: correct,
      durationSeconds: _elapsedSeconds,
      passScore: data.config.passScore,
      timeLimitSeconds: data.config.timeLimitSeconds,
    );
    Navigator.pushReplacementNamed(
      context,
      ResultScreen.routeName,
      arguments: result,
    );
  }
}

class _QuizData {
  const _QuizData({required this.config, required this.questions});

  final AssignmentConfig config;
  final List<Question> questions;
}
