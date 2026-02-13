import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../config/app_engine_config.dart';
import '../models/assignment_config.dart';
import '../models/navigation_args.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import '../services/assignment_rules_loader.dart';
import '../services/question_bank_loader.dart';
import 'result_screen.dart';

part 'quiz_screen.header.dart';
part 'quiz_screen.input.dart';
part 'quiz_screen.questions.dart';
part 'quiz_screen.widgets.dart';
part 'quiz_screen.models.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  static const String routeName = '/quiz';

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _rulesLoader = AssignmentRulesLoader(
    assetPath: appEngineConfig.assignmentRulesAssetPath,
  );
  final _bankLoader = QuestionBankLoader(
    assetBasePath: appEngineConfig.questionBankBasePath,
    useGradeSubdirectory: appEngineConfig.useGradeSubdirectory,
  );
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
  bool _inQuestionPhase = false;
  bool _started = false;
  bool _inputPanelCollapsed = false;
  Offset _floatingPanelOffset = const Offset(20, 120);
  bool _floatingInitialized = false;
  String? _pdfLoadError;

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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('かいとう ちゅうは もどれません')));
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
                    const Text('もんだいが みつかりません'),
                    const SizedBox(height: 8),
                    Text('grade=${args.grade}, taskKey=${args.taskKey}'),
                  ],
                ),
              );
            }
            _ensureControllers(data.questions);
            return Column(
              children: [
                _buildHeader(data.config, args, data),
                const Divider(height: 1),
                Expanded(
                  child: _inQuestionPhase
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final isPortrait =
                                MediaQuery.of(context).orientation ==
                                Orientation.portrait;
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
                                          final question =
                                              data.questions[index];
                                          return _buildQuestionTile(
                                            question,
                                            index,
                                          );
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
                                      return _buildQuestionTile(
                                        question,
                                        index,
                                      );
                                    },
                                  ),
                                ),
                                _buildFloatingInputPanel(constraints),
                              ],
                            );
                          },
                        )
                      : _buildExplanationView(data),
                ),
              ],
            );
          },
        ),
      ),
    );
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
    final rMatch = RegExp(
      r'^\s*(-?\d+)\s*(?:r\s*(-?\d+))?\s*$',
      caseSensitive: false,
    ).firstMatch(expected);
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
      keyboardType: _inputMode == InputMode.system
          ? keyboardType
          : TextInputType.none,
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
    return '$line1\n$line2';
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
    final explanationPdfAsset = await _findExplanationPdfAsset(args);
    return _QuizData(
      config: config,
      questions: questions,
      explanationPdfAsset: explanationPdfAsset,
    );
  }

  Future<String?> _findExplanationPdfAsset(TaskArgs args) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    final basePrefix = 'assets/explanations/g${args.grade}/';
    final candidates =
        assets
            .where((path) => path.startsWith(basePrefix))
            .where((path) => path.toLowerCase().endsWith('.pdf'))
            .toList()
          ..sort();
    if (candidates.isEmpty) return null;

    final exact = '$basePrefix${args.taskKey}.pdf';
    if (candidates.contains(exact)) return exact;

    final prefixMatch = candidates.where((path) {
      final fileName = path.split('/').last.toLowerCase();
      return fileName.startsWith(args.taskKey.toLowerCase());
    }).toList();
    if (prefixMatch.isNotEmpty) return prefixMatch.first;
    return null;
  }

  Widget _buildExplanationView(_QuizData data) {
    final asset = data.explanationPdfAsset;
    if (asset == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'このコースは せつめい がありません',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    if (_pdfLoadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'せつめいを ひらけませんでした\\n\\n$_pdfLoadError',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    return SfPdfViewer.asset(
      asset,
      onDocumentLoadFailed: (details) {
        if (!mounted) return;
        setState(() {
          _pdfLoadError = details.description;
        });
      },
    );
  }

  void _ensureControllers(List<Question> questions) {
    final expectedFieldCount = questions.fold<int>(0, (total, question) {
      if (question.type == QuestionType.divide) return total + 2;
      if (question.type == QuestionType.divideLong) {
        return total + _divideLongFieldCount(question.expectedAnswer);
      }
      return total + 1;
    });
    final needsRebuild =
        _questionFields.length != questions.length ||
        _controllers.length != expectedFieldCount;
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
          _AnswerFieldBinding(indices: [fieldIndex, fieldIndex + 1]),
        );
        fieldIndex += 2;
        continue;
      }
      if (question.type == QuestionType.divideLong) {
        final count = _divideLongFieldCount(question.expectedAnswer);
        _questionFields.add(
          _AnswerFieldBinding(
            indices: List.generate(count, (i) => fieldIndex + i),
          ),
        );
        fieldIndex += count;
        continue;
      }
      _questionFields.add(_AnswerFieldBinding(indices: [fieldIndex]));
      fieldIndex += 1;
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

      if (question.type == QuestionType.divideLong) {
        final expectedSteps = _parseDivideLongExpected(expected);
        final indices = binding.indices;
        final inputs = indices
            .map((idx) => _normalizeIntInput(_controllers[idx].text.trim()))
            .toList();
        final expectedNormalized = expectedSteps
            .map((value) => _normalizeIntInput(value))
            .toList();
        final isCorrect =
            expectedNormalized.isNotEmpty &&
            inputs.length == expectedNormalized.length &&
            _listsEqual(inputs, expectedNormalized);
        if (isCorrect) {
          correct++;
        }
        reviews.add(
          ReviewItem(
            raw: question.raw,
            type: question.type.name,
            expected: expectedSteps.join(','),
            input: inputs.join(','),
          ),
        );
      } else if (question.type == QuestionType.divide) {
        final quotientInputRaw = _controllers[binding.quotientIndex].text
            .trim();
        final remainderIndex = binding.remainderIndex ?? binding.quotientIndex;
        final remainderInputRaw = _controllers[remainderIndex].text.trim();
        final normalizedQuotientInput = _normalizeIntInput(quotientInputRaw);
        final normalizedRemainderInput = _normalizeIntInput(
          remainderInputRaw.isEmpty ? '0' : remainderInputRaw,
        );
        var isCorrect = false;
        var expectedForReview = expected ?? '';
        if (expected != null && expected.isNotEmpty) {
          final parts = _parseDivideAnswer(expected);
          if (parts != null) {
            isCorrect =
                normalizedQuotientInput == parts.quotient &&
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
            normalizedQuotientInput.isNotEmpty ||
            normalizedRemainderInput.isNotEmpty;
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
    final effectivePassScore = data.config.passScore <= 0
        ? data.questions.length
        : data.config.passScore;
    final cappedPassScore = effectivePassScore > data.questions.length
        ? data.questions.length
        : effectivePassScore;
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
    if (key == '竚ｫ') {
      if (text.isNotEmpty) {
        controller.text = text.substring(0, text.length - 1);
      }
      return;
    }
    controller.text = '$text$key';
  }

  void _goToHomework() {
    if (_inQuestionPhase) return;
    setState(() {
      _inQuestionPhase = true;
      _inputPanelCollapsed = false;
    });
  }

  void _startQuiz() {
    setState(() {
      _started = true;
      _pdfLoadError = null;
    });
    _startTimerIfNeeded();
  }

  void _toggleInputPanel() {
    setState(() {
      _inputPanelCollapsed = !_inputPanelCollapsed;
    });
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  int _divideLongFieldCount(String? expected) {
    final steps = _parseDivideLongExpected(expected);
    return steps.isEmpty ? 1 : steps.length;
  }

  List<String> _parseDivideLongExpected(String? expected) {
    if (expected == null) return const [];
    final trimmed = expected.trim();
    if (trimmed.isEmpty) return const [];
    return trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
