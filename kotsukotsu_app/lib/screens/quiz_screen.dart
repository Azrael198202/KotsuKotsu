import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../models/assignment_config.dart';
import '../models/navigation_args.dart';
import '../models/question.dart';
import '../models/question_type.dart';
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
  final _focusNodes = <FocusNode>[];
  final _questionFields = <_AnswerFieldBinding>[];
  final ScrollController _scrollController = ScrollController();
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int _elapsedSeconds = 0;
  Future<_QuizData>? _quizFuture;
  TaskArgs? _lastArgs;
  int _activeIndex = 0;
  InputMode _inputMode = InputMode.keypad;
  bool _started = false;
  bool _inputPanelCollapsed = true;
  Offset _floatingPanelOffset = const Offset(20, 120);
  bool _floatingInitialized = false;

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TaskArgs;
    if (_quizFuture == null || _lastArgs != args) {
      _lastArgs = args;
      _quizFuture = _loadData(args);
    }
    return PopScope(
      canPop: !_started,
      onPopInvoked: (didPop) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提出後に戻ることができます')),
        );
      },
      child: Scaffold(
        body: FutureBuilder<_QuizData>(
          future: _quizFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null || data.questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('問題が見つかりません'),
                    const SizedBox(height: 8),
                    Text('grade=${args.grade}, taskKey=${args.taskKey}'),
                  ],
                ),
              );
            }
            _ensureControllers(data.questions);
            if (_started) {
              _startTimerIfNeeded();
            }
            return Column(
              children: [
                _buildHeader(data.config, args, data),
                const Divider(height: 1),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isPortrait =
                          MediaQuery.of(context).orientation == Orientation.portrait;
                      if (!isPortrait) {
                        return Row(
                          children: [
                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: data.questions.length,
                                  itemBuilder: (context, index) {
                                    final question = data.questions[index];
                                    return _buildQuestionTile(question, index);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildInputPanelShell(),
                            const SizedBox(width: 16),
                          ],
                        );
                      }
                      return Stack(
                        children: [
                          Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: data.questions.length,
                              itemBuilder: (context, index) {
                                final question = data.questions[index];
                                return _buildQuestionTile(question, index);
                              },
                            ),
                          ),
                          _buildFloatingInputPanel(constraints),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AssignmentConfig config, TaskArgs args, _QuizData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HeaderBackButton(
            enabled: !_started,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                args.taskName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text('制限時間: ${config.timeLimitSeconds}秒'),
              const SizedBox(height: 6),
              Text('合格点: ${config.passScore}点'),
            ],
          ),
          const Spacer(),
          _buildHeaderClock(),
          const Spacer(),
          if (!_started)
            _RoundActionButton(
              color: const Color(0xFF2E7D32),
              icon: Icons.play_arrow,
              tooltip: '開始',
              onPressed: _startQuiz,
            )
          else
            _RoundActionButton(
              color: const Color(0xFF1976D2),
              icon: Icons.description,
              tooltip: '提出',
              onPressed: () => _submit(args, data),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderClock() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCCE1F2), width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 22, color: Color(0xFF1976D2)),
          const SizedBox(height: 4),
          Text(
            '$_elapsedSeconds',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2B3C),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '秒',
            style: TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return Column(
      children: [
        SegmentedButton<InputMode>(
          segments: const [
            ButtonSegment(
              value: InputMode.keypad,
              label: Text('キー入力'),
              icon: Icon(Icons.dialpad),
            ),
            ButtonSegment(
              value: InputMode.handwriting,
              label: Text('手書き'),
              icon: Icon(Icons.draw),
            ),
            ButtonSegment(
              value: InputMode.system,
              label: Text('端末'),
              icon: Icon(Icons.keyboard),
            ),
          ],
          selected: {_inputMode},
          onSelectionChanged: (value) {
            setState(() {
              _inputMode = value.first;
            });
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _inputMode == InputMode.keypad
                ? _buildKeypad()
                : _inputMode == InputMode.handwriting
                    ? _buildHandwritingPad()
                    : _buildSystemKeyboardHint(),
          ),
        ),
      ],
    );
  }

  Widget _buildInputPanelShell() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _inputPanelCollapsed ? 52 : 280,
      constraints: _inputPanelCollapsed
          ? const BoxConstraints.tightFor(width: 64, height: 84)
          : const BoxConstraints.tightFor(width: 280, height: 520),
      child: _inputPanelCollapsed
          ? _buildCollapsedToggle()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    const Text(
                      '入力',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '畳む',
                      onPressed: _toggleInputPanel,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Flexible(child: _buildInputPanel()),
              ],
            ),
    );
  }

  Widget _buildFloatingInputPanel(BoxConstraints constraints) {
    final panelWidth = _inputPanelCollapsed ? 64.0 : 280.0;
    final panelHeight = _inputPanelCollapsed ? 84.0 : 520.0;
    final maxX = (constraints.maxWidth - panelWidth).clamp(0.0, constraints.maxWidth);
    final maxY = (constraints.maxHeight - panelHeight).clamp(0.0, constraints.maxHeight);
    if (!_floatingInitialized) {
      _floatingPanelOffset = Offset(maxX, maxY / 2);
      _floatingInitialized = true;
    }
    final clamped = Offset(
      _floatingPanelOffset.dx.clamp(0.0, maxX),
      _floatingPanelOffset.dy.clamp(0.0, maxY),
    );
    if (clamped != _floatingPanelOffset) {
      _floatingPanelOffset = clamped;
    }
    return Positioned(
      left: _floatingPanelOffset.dx,
      top: _floatingPanelOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _floatingPanelOffset += details.delta;
          });
        },
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: SizedBox(
            width: panelWidth,
            height: panelHeight,
            child: _buildInputPanelShell(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C4),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: IconButton(
            tooltip: '開く',
            onPressed: _toggleInputPanel,
            icon: const Icon(Icons.pan_tool_alt, color: Color(0xFFF9A825), size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      '1',
      '2',
      '3',
      '-',
      '4',
      '5',
      '6',
      '/',
      '7',
      '8',
      '9',
      ':',
      '0',
      '.',
      'r',
      'C',
      '',
      '⌫',
      '',
      '',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: GridView.builder(
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final key = keys[index];
          if (key.isEmpty) {
            return const SizedBox.shrink();
          }
          return ElevatedButton(
            onPressed: () => _handleKeyPress(key),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            ),
            child: AutoSizeText(
              key,
              maxLines: 1,
              minFontSize: 14,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandwritingPad() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFE7F2)),
      ),
      child: Column(
        children: [
          const Text(
            '手書き認識（ローカル）',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E6EF)),
              ),
              child: const Center(
                child: Text('認識エンジン未実装'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: null,
            child: const Text('認識'),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemKeyboardHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFE7F2)),
      ),
      child: const Center(
        child: Text('端末キーボードで入力してください'),
      ),
    );
  }

  Widget _buildQuestionTile(Question question, int index) {
    return _PaperCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              '第${index + 1}問',
              maxLines: 1,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildQuestionBody(question, index),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineMathAnswer(Question question, int index, {required String hint}) {
    final expression = _displayExpression(question.raw);
    final fieldIndex = _questionFields[index].quotientIndex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _MathPrompt(expression: expression)),
        const SizedBox(width: 60),
        const Text('=', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: _buildAnswerField(
            fieldIndex,
            hint: hint,
            keyboardType: TextInputType.number,
            enabled: _started,
          ),
        ),
        const SizedBox(width: 50),
        const _ScratchPad(width: 200, height: 80),
      ],
    );
  }

  Widget _buildInlineDivisionAnswer(Question question, int index) {
    final expression = _displayExpression(question.raw);
    final binding = _questionFields[index];
    final quotientIndex = binding.quotientIndex;
    final remainderIndex = binding.remainderIndex ?? binding.quotientIndex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _MathPrompt(expression: expression)),
        const SizedBox(width: 24),
        const Text('=', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        const Text('Quot.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: _buildAnswerField(
            quotientIndex,
            hint: 'Quot.',
            keyboardType: TextInputType.number,
            enabled: _started,
          ),
        ),
        const SizedBox(width: 16),
        const Text('Rem.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: _buildAnswerField(
            remainderIndex,
            hint: 'Rem.',
            keyboardType: TextInputType.number,
            enabled: _started,
          ),
        ),
        const SizedBox(width: 24),
        const _ScratchPad(width: 200, height: 80),
      ],
    );
  }

  Widget _buildWordQuestion(Question question, int index) {
    final text = question.raw.replaceFirst('[WORD]', '').trim();
    final fieldIndex = _questionFields[index].quotientIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          text.isEmpty ? '問題文がありません' : text,
          maxLines: 4,
          minFontSize: 14,
          style: const TextStyle(fontSize: 20, height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const AutoSizeText(
              '答え',
              maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: _buildAnswerField(
                fieldIndex,
                hint: '答え',
                keyboardType: TextInputType.number,
                enabled: _started,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionBody(Question question, int index) {
    switch (question.type) {
      case QuestionType.word:
        return _buildWordQuestion(question, index);
      case QuestionType.addSubColumn:
        return _buildColumnQuestion(question, index, hint: 'Answer');
      case QuestionType.multiplyColumn:
        return _buildColumnQuestion(
          question,
          index,
          hint: '答え',
          overrideOperator: '×',
        );
      case QuestionType.divideLong:
        return _buildLongDivision(question, index);
      case QuestionType.fraction:
        return _buildInlineMathAnswer(question, index, hint: '分数の答え（例: 1/2）');
      case QuestionType.ratio:
        return _buildInlineMathAnswer(question, index, hint: '比（例: 2:3）');
      case QuestionType.decimal:
      case QuestionType.addSub:
      case QuestionType.multiply:
        return _buildInlineMathAnswer(question, index, hint: '答え');
      case QuestionType.divide:
        return _buildInlineDivisionAnswer(question, index);
      case QuestionType.unknown:
        return _buildInlineMathAnswer(question, index, hint: '答え');
    }
  }

  Widget _buildColumnQuestion(
    Question question,
    int index, {
    required String hint,
    String? overrideOperator,
  }) {
    final parsed = _parseBinary(question.raw);
    final op = overrideOperator ?? parsed?.op ?? '';
    final left = parsed?.left ?? '';
    final right = parsed?.right ?? '';
    final column = _renderColumn(left, right, op);
    final fieldIndex = _questionFields[index].quotientIndex;
    const style = TextStyle(fontFamily: 'monospace', fontSize: 26, height: 1.2);
    final answerWidth = _columnAnswerWidth(column, style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                column,
                style: style,
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: answerWidth,
                child: _buildAnswerField(fieldIndex, hint: hint, enabled: _started),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: _ScratchPad(height: 200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLongDivision(Question question, int index) {
    final parsed = _parseBinary(question.raw);
    final dividend = parsed?.left ?? '';
    final divisor = parsed?.right ?? '';
    final line = '${divisor.isEmpty ? '' : divisor} ) $dividend';
    final fieldIndex = _questionFields[index].quotientIndex;
    const style = TextStyle(fontFamily: 'monospace', fontSize: 26, height: 1.2);
    final answerWidth = _columnAnswerWidth(line, style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line,
                style: style,
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: answerWidth,
                child: _buildAnswerField(index, hint: '商 r 余り（例: 12 r3）', enabled: _started),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: _ScratchPad(height: 200),
            ),
          ),
        ),
      ],
    );
  }

  double _columnAnswerWidth(String text, TextStyle style) {
    final lines = text.split('\n');
    var longest = '';
    for (final line in lines) {
      if (line.length > longest.length) {
        longest = line;
      }
    }
    final painter = TextPainter(
      text: TextSpan(text: longest, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width + 24;
    return width.clamp(140, 260);
  }

  String _normalizeIntInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final parsed = int.tryParse(trimmed);
    return parsed?.toString() ?? trimmed;
  }

  _DivideParts? _parseDivideAnswer(String expected) {
    final comma = RegExp(r'^\s*(-?\d+)\s*,\s*(-?\d+)\s*$');
    final commaMatch = comma.firstMatch(expected);
    if (commaMatch != null) {
      return _DivideParts(
        quotient: _normalizeIntInput(commaMatch.group(1) ?? ''),
        remainder: _normalizeIntInput(commaMatch.group(2) ?? ''),
      );
    }
    final rMatch = RegExp(r'^\s*(-?\d+)\s*(?:r\s*(-?\d+))?\s*$',
            caseSensitive: false)
        .firstMatch(expected);
    if (rMatch != null) {
      return _DivideParts(
        quotient: _normalizeIntInput(rMatch.group(1) ?? ''),
        remainder: _normalizeIntInput(rMatch.group(2) ?? '0'),
      );
    }
    return null;
  }

  Widget _buildAnswerField(
    int controllerIndex, {
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: _controllers[controllerIndex],
      focusNode: _focusNodes[controllerIndex],
      keyboardType: _inputMode == InputMode.system ? keyboardType : TextInputType.none,
      readOnly: !enabled || _inputMode != InputMode.system,
      showCursor: enabled,
      onTap: enabled ? () => _setActiveIndex(controllerIndex) : null,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF8D6),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        hintText: hint,
      ),
    );
  }

  _BinaryExpression? _parseBinary(String raw) {
    final normalized = raw
        .replaceAll('\u00d7', '*')
        .replaceAll('\u00f7', '/')
        .replaceAll('x', '*')
        .replaceAll('X', '*');
    final match = RegExp(
      r'^\s*(\d+(?:\.\d+)?)\s*([+\-*/])\s*(\d+(?:\.\d+)?)\s*=?\s*$',
    ).firstMatch(normalized);
    if (match == null) return null;
    return _BinaryExpression(
      left: match.group(1)!,
      op: match.group(2)!,
      right: match.group(3)!,
    );
  }

  String _renderColumn(String left, String right, String op) {
    if (left.isEmpty || right.isEmpty || op.isEmpty) {
      return _displayExpression(left + op + right);
    }
    final width = (left.length > right.length ? left.length : right.length) + 2;
    final line1 = left.padLeft(width);
    final line2 = '$op ${right.padLeft(width - 2)}';
    final line3 = ''.padLeft(width, '-');
    return '$line1\n$line2\n$line3';
  }

  String _displayExpression(String raw) {
    return raw.replaceAll('=', '').trim();
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

  void _ensureControllers(List<Question> questions) {
    final expectedFieldCount = questions.fold<int>(
      0,
      (total, question) => total + (question.type == QuestionType.divide ? 2 : 1),
    );
    final needsRebuild =
        _questionFields.length != questions.length || _controllers.length != expectedFieldCount;
    if (!needsRebuild) return;

    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }

    _questionFields.clear();
    var fieldIndex = 0;
    for (final question in questions) {
      if (question.type == QuestionType.divide) {
        _questionFields.add(
          _AnswerFieldBinding(quotientIndex: fieldIndex, remainderIndex: fieldIndex + 1),
        );
        fieldIndex += 2;
      } else {
        _questionFields.add(_AnswerFieldBinding(quotientIndex: fieldIndex));
        fieldIndex += 1;
      }
    }

    _controllers
      ..clear()
      ..addAll(List.generate(fieldIndex, (_) => TextEditingController()));
    _focusNodes
      ..clear()
      ..addAll(List.generate(fieldIndex, (_) => FocusNode()));
    _activeIndex = 0;
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
    final reviews = <ReviewItem>[];
    for (var i = 0; i < data.questions.length; i++) {
      final question = data.questions[i];
      final expected = question.expectedAnswer;
      final binding = _questionFields[i];

      if (question.type == QuestionType.divide) {
        final quotientInputRaw = _controllers[binding.quotientIndex].text.trim();
        final remainderIndex = binding.remainderIndex ?? binding.quotientIndex;
        final remainderInputRaw = _controllers[remainderIndex].text.trim();
        final normalizedQuotientInput = _normalizeIntInput(quotientInputRaw);
        final normalizedRemainderInput =
            _normalizeIntInput(remainderInputRaw.isEmpty ? '0' : remainderInputRaw);
        var isCorrect = false;
        var expectedForReview = expected ?? '';
        if (expected != null && expected.isNotEmpty) {
          final parts = _parseDivideAnswer(expected);
          if (parts != null) {
            isCorrect = normalizedQuotientInput == parts.quotient &&
                normalizedRemainderInput == parts.remainder;
            expectedForReview = '${parts.quotient},${parts.remainder}';
          } else {
            isCorrect = normalizedQuotientInput == _normalizeIntInput(expected);
          }
        }
        if (isCorrect) {
          correct++;
        }
        final hasInput =
            normalizedQuotientInput.isNotEmpty || normalizedRemainderInput.isNotEmpty;
        final inputForReview = hasInput
            ? '${normalizedQuotientInput.isEmpty ? '0' : normalizedQuotientInput},'
                '${normalizedRemainderInput.isEmpty ? '0' : normalizedRemainderInput}'
            : '';
        reviews.add(
          ReviewItem(
            raw: question.raw,
            type: question.type.name,
            expected: expectedForReview,
            input: inputForReview,
          ),
        );
      } else {
        final input = _controllers[binding.quotientIndex].text.trim();
        if (expected != null && expected.isNotEmpty && input == expected) {
          correct++;
        }
        reviews.add(
          ReviewItem(
            raw: question.raw,
            type: question.type.name,
            expected: expected ?? '',
            input: input,
          ),
        );
      }
    }
    final effectivePassScore =
        data.config.passScore <= 0 ? data.questions.length : data.config.passScore;
    final cappedPassScore =
        effectivePassScore > data.questions.length ? data.questions.length : effectivePassScore;
    final result = ResultArgs(
      grade: args.grade,
      taskKey: args.taskKey,
      taskName: args.taskName,
      total: data.questions.length,
      correct: correct,
      durationSeconds: _elapsedSeconds,
      passScore: cappedPassScore,
      timeLimitSeconds: data.config.timeLimitSeconds,
      reviews: reviews,
    );
    Navigator.pushReplacementNamed(
      context,
      ResultScreen.routeName,
      arguments: result,
    );
  }

  void _setActiveIndex(int index) {
    if (_activeIndex == index) return;
    setState(() {
      _activeIndex = index;
    });
    if (index >= 0 && index < _focusNodes.length) {
      _focusNodes[index].requestFocus();
    }
  }

  void _handleKeyPress(String key) {
    if (!_started) return;
    if (_activeIndex < 0 || _activeIndex >= _controllers.length) return;
    final controller = _controllers[_activeIndex];
    final text = controller.text;
    if (key == 'C') {
      controller.text = '';
      return;
    }
    if (key == '⌫') {
      if (text.isNotEmpty) {
        controller.text = text.substring(0, text.length - 1);
      }
      return;
    }
    controller.text = '$text$key';
  }

  void _startQuiz() {
    setState(() {
      _started = true;
    });
    _startTimerIfNeeded();
  }

  void _toggleInputPanel() {
    setState(() {
      _inputPanelCollapsed = !_inputPanelCollapsed;
    });
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onPressed : null,
      radius: 22,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
      ),
    );
  }
}

class _MathPrompt extends StatelessWidget {
  const _MathPrompt({required this.expression});

  final String expression;

  @override
  Widget build(BuildContext context) {
    if (expression.isEmpty) {
      return const Text('式が読み取れません');
    }
    return AutoSizeText(
      expression,
      maxLines: 1,
      minFontSize: 18,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({
    required this.child,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
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
      child: CustomPaint(
        painter: _PaperLinePainter(),
        child: child,
      ),
    );
  }
}

class _PaperLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAF1F7)
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperLinePainter oldDelegate) => false;
}

class _ScratchPad extends StatefulWidget {
  const _ScratchPad({this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<_ScratchPad> createState() => _ScratchPadState();
}

class _ScratchPadState extends State<_ScratchPad> {
  final List<Offset?> _points = <Offset?>[];

  void _clear() {
    setState(_points.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E6EF)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.globalPosition);
                setState(() => _points.add(local));
              },
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.globalPosition);
                setState(() => _points.add(local));
              },
              onPanEnd: (_) => setState(() => _points.add(null)),
              child: CustomPaint(
                painter: _ScratchPainter(points: _points),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: _clear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE0E6EF)),
                ),
                child: const Text(
                  '消去',
                  style: TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  _ScratchPainter({required this.points});

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A3B4C)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

enum InputMode {
  keypad,
  handwriting,
  system,
}

class _QuizData {
  const _QuizData({required this.config, required this.questions});

  final AssignmentConfig config;
  final List<Question> questions;
}

class _BinaryExpression {
  const _BinaryExpression({
    required this.left,
    required this.op,
    required this.right,
  });

  final String left;
  final String op;
  final String right;
}

class _AnswerFieldBinding {
  const _AnswerFieldBinding({required this.quotientIndex, this.remainderIndex});

  final int quotientIndex;
  final int? remainderIndex;
}

class _DivideParts {
  const _DivideParts({required this.quotient, required this.remainder});

  final String quotient;
  final String remainder;
}
