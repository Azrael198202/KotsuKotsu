import 'dart:async';

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
  bool _popupPrepared = false;
  bool _showPopup = false;
  bool _popupVisible = false;
  _ResultPopupType _popupType = _ResultPopupType.pass;
  Timer? _hidePopupTimer;
  Timer? _removePopupTimer;

  @override
  void dispose() {
    _hidePopupTimer?.cancel();
    _removePopupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ResultArgs;
    final navConfig = AppNavigationScope.of(context);

    if (!_recorded) {
      _recorded = true;
      TaskProgressStore.recordResult(args);
      PracticeHistoryService.record(args);
    }

    _preparePopupIfNeeded(args);

    final pass = args.isPassed;

    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pass ? '合格' : 'もういちど',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text('スコア ${args.correct}/${args.total}'),
                Text(
                  '時間 ${args.durationSeconds}s / 制限 ${args.timeLimitSeconds}s',
                ),
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
                    child: const Text('もういちど挑戦'),
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
                  child: Text(
                    navConfig.allowGradeSelection ? '学年選択へ戻る' : '課題選択へ戻る',
                  ),
                ),
              ],
            ),
          ),
          if (_showPopup)
            _ResultPopupOverlay(type: _popupType, visible: _popupVisible),
        ],
      ),
    );
  }

  void _preparePopupIfNeeded(ResultArgs args) {
    if (_popupPrepared) return;
    _popupPrepared = true;

    final inTime =
        args.timeLimitSeconds <= 0 ||
        args.durationSeconds <= args.timeLimitSeconds;
    final fullScore = args.total > 0 && args.correct == args.total;

    if (inTime && fullScore) {
      _popupType = _ResultPopupType.perfect;
    } else if (inTime && args.isPassed) {
      _popupType = _ResultPopupType.pass;
    } else {
      _popupType = _ResultPopupType.fail;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showPopup = true;
        _popupVisible = true;
      });

      _hidePopupTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _popupVisible = false;
        });
      });

      _removePopupTimer = Timer(const Duration(milliseconds: 1900), () {
        if (!mounted) return;
        setState(() {
          _showPopup = false;
        });
      });
    });
  }
}

enum _ResultPopupType { perfect, pass, fail }

class _ResultPopupOverlay extends StatelessWidget {
  const _ResultPopupOverlay({required this.type, required this.visible});

  final _ResultPopupType type;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: Container(
            color: const Color(0x22000000),
            alignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.72, end: visible ? 1 : 0.88),
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: _buildPopupContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupContent() {
    switch (type) {
      case _ResultPopupType.perfect:
        return _PerfectBadge();
      case _ResultPopupType.pass:
        return _PassBadge();
      case _ResultPopupType.fail:
        return _FailBadge();
    }
  }
}

class _PerfectBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE53935), width: 12),
              color: Colors.white.withValues(alpha: 0.94),
            ),
          ),
          Container(
            width: 238,
            height: 238,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF8A80), width: 8),
            ),
          ),
          const Text(
            'まんてん',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF9800), width: 11),
              color: Colors.white.withValues(alpha: 0.94),
            ),
          ),
          const Text(
            'こうかく',
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w900,
              color: Color(0xFFEF6C00),
            ),
          ),
        ],
      ),
    );
  }
}

class _FailBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CryingChildFace(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF90A4AE), width: 2),
            ),
            child: const Text(
              'ざんねん',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Color(0xFF455A64),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CryingChildFace extends StatelessWidget {
  const _CryingChildFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFE0B2),
        border: Border.all(color: const Color(0xFF8D6E63), width: 3),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 22,
            left: 18,
            child: Container(
              width: 114,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const Positioned(top: 63, left: 48, child: _Eye()),
          const Positioned(top: 63, right: 48, child: _Eye()),
          Positioned(
            top: 79,
            left: 44,
            child: Container(
              width: 10,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            top: 79,
            right: 44,
            child: Container(
              width: 10,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 34,
            left: 50,
            child: Container(
              width: 50,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF5D4037), width: 3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        shape: BoxShape.circle,
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
              '問題 ${index + 1}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildQuestionBody(item),
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                const Text('='),
                _AnswerBox(
                  value: input.isEmpty ? ' ' : input,
                  strike: expected.isNotEmpty && !isCorrect,
                ),
                FilledButton.tonal(
                  onPressed: onToggle,
                  child: Text(showAnswer ? '答えを隠す' : '答えを見る'),
                ),
                if (showAnswer)
                  Text(
                    hasExpected ? expected : '正解データなし',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: hasExpected
                          ? const Color(0xFFD32F2F)
                          : Colors.black54,
                    ),
                  ),
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
    final tex = expression
        .replaceAll('×', r'\times ')
        .replaceAll('÷', r'\div ');

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
          Positioned.fill(child: CustomPaint(painter: _StrikePainter())),
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
