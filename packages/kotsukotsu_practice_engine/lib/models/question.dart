import 'question_type.dart';

class Question {
  Question({
    required this.id,
    required this.raw,
    required this.type,
    this.expectedAnswer,
  });

  final String id;
  final String raw;
  final QuestionType type;
  final String? expectedAnswer;
}
