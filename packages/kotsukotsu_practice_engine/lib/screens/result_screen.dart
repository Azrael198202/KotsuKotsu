import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../config/app_navigation_config.dart';
import '../models/navigation_args.dart';
import '../services/practice_history_service.dart';
import '../services/task_progress_store.dart';
import 'grade_select_screen.dart';
import 'quiz_screen.dart';
import 'task_select_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  static const String routeName = '/result';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Set<int> _revealed = <int>{};
  bool _recorded = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ResultArgs;
    final navConfig = AppNavigationScope.of(context);
    if (!_recorded) {
      _recorded = true;
      TaskProgressStore.recordResult(args);
      PracticeHistoryService.record(args);
    }
    final pass = args.isPassed;

    return Scaffold(
      appBar: AppBar(title: const Text('结果')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pass ? '通过' : '未通过',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('得分: ${args.correct}/${args.total}'),
            Text('用时: ${args.durationSeconds}s / 限时: ${args.timeLimitSeconds}s'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: args.reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = args.reviews[index];
                  final showAnswer = _revealed.contains(index);
                  return _ReviewCard(
                    index: index,
                    item: item,
                    showAnswer: showAnswer,
                    onToggle: () {
                      setState(() {
                        if (showAnswer) {
                          _revealed.remove(index);
                        } else {
                          _revealed.add(index);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
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
                child: const Text('再做一次'),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                if (navConfig.allowGradeSelection) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    GradeSelectScreen.routeName,
                    (route) => false,
                  );
                  return;
                }
                final grade = navConfig.fixedGrade ?? args.grade;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  TaskSelectScreen.routeName,
                  (route) => false,
                  arguments: GradeArgs(grade: grade),
                );
              },
              child: Text(navConfig.allowGradeSelection ? '选择年级' : '返回任务'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.index,
    required this.item,
    required this.showAnswer,
    required this.onToggle,
  });

  final int index;
  final ReviewItem item;
  final bool showAnswer;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final expected = item.expected;
    final input = item.input;
    final hasExpected = expected.isNotEmpty;
    final isCorrect = hasExpected && input == expected;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${index + 1}题',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildQuestionBody(item),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('='),
                const SizedBox(width: 10),
                _AnswerBox(
                  value: input.isEmpty ? ' ' : input,
                  strike: expected.isNotEmpty && !isCorrect,
                ),
                const SizedBox(width: 16),
                FilledButton.tonal(
                  onPressed: onToggle,
                  child: Text(showAnswer ? '隐藏答案' : '显示答案'),
                ),
                if (showAnswer) ...[
                  const SizedBox(width: 12),
                  Text(
                    hasExpected ? expected : '无标准答案',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: hasExpected ? const Color(0xFFD32F2F) : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBody(ReviewItem item) {
    if (item.type == 'word') {
      return Text(item.raw.replaceFirst('[WORD]', '').trim());
    }
    final expression = item.raw
        .replaceAll('*', '×')
        .replaceAll('/', '÷')
        .replaceAll('=', '')
        .trim();
    final tex = expression.replaceAll('×', r'\times ').replaceAll('÷', r'\div ');
    return Math.tex(
      tex,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.value, required this.strike});

  final String value;
  final bool strike;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8D6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        if (strike)
          Positioned.fill(
            child: CustomPaint(
              painter: _StrikePainter(),
            ),
          ),
      ],
    );
  }
}

class _StrikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(8, size.height - 6),
      Offset(size.width - 8, 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
