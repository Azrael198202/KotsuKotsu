part of 'quiz_screen.dart';

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
  const _AnswerFieldBinding({required this.indices});

  final List<int> indices;

  int get quotientIndex => indices.first;
  int? get remainderIndex => indices.length > 1 ? indices[1] : null;
}

class _DivideParts {
  const _DivideParts({required this.quotient, required this.remainder});

  final String quotient;
  final String remainder;
}
