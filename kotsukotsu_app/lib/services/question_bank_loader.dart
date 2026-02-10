import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';
import 'question_parser.dart';

class QuestionBankLoader {
  QuestionBankLoader({QuestionParser? parser}) : _parser = parser ?? QuestionParser();

  final QuestionParser _parser;

  Future<List<Question>> loadQuestions({
    required int grade,
    required String taskKey,
  }) async {
    final manifestRaw = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;

    final prefix = 'assets/question_bank/g$grade/';
    final matches = manifest.keys
        .where((path) => path.startsWith(prefix))
        .where((path) => path.endsWith('.txt'))
        .where((path) {
          final fileName = path.split('/').last;
          return fileName.startsWith(taskKey);
        })
        .toList()
      ..sort();

    if (matches.isEmpty) {
      final fallback = '$prefix$taskKey.txt';
      if (manifest.containsKey(fallback)) {
        matches.add(fallback);
      }
    }

    final questions = <Question>[];
    for (final path in matches) {
      final raw = await rootBundle.loadString(path);
      final lines = raw.split(RegExp(r'\\r?\\n')).where((line) => line.trim().isNotEmpty);
      var index = 0;
      for (final line in lines) {
        final id = '${path.split('/').last}-$index';
        questions.add(_parser.parse(id: id, raw: line, sourceName: path));
        index++;
      }
    }
    return questions;
  }
}
