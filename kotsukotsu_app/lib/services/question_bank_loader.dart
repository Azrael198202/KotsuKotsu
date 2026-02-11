import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/question.dart';
import 'question_parser.dart';

class QuestionBankLoader {
  QuestionBankLoader({
    QuestionParser? parser,
    this.assetBasePath = 'assets/question_bank',
    this.useGradeSubdirectory = true,
  }) : _parser = parser ?? QuestionParser();

  final QuestionParser _parser;
  final String assetBasePath;
  final bool useGradeSubdirectory;

  String _prefixForGrade(int grade) {
    final base = assetBasePath.endsWith('/')
        ? assetBasePath.substring(0, assetBasePath.length - 1)
        : assetBasePath;
    if (useGradeSubdirectory) {
      return '$base/g$grade/';
    }
    return '$base/';
  }

  Future<List<Question>> loadQuestions({
    required int grade,
    required String taskKey,
  }) async {
    debugPrint('Loading questions: grade=$grade, taskKey=$taskKey');
    // Ensure logs show up even if debugPrint is throttled.
    // ignore: avoid_print
    print('Loading questions: grade=$grade, taskKey=$taskKey');
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      // All assets in the bundle; if this is 0, assets are not packaged.
      debugPrint('Total assets: ${assets.length}');
      // ignore: avoid_print
      print('Total assets: ${assets.length}');

      final prefix = _prefixForGrade(grade);
      // List all question bank txt files for this grade.
      final allForGrade = assets
          .where((path) => path.startsWith(prefix))
          .where((path) => path.endsWith('.txt'))
          .toList()
        ..sort();
      debugPrint('Asset prefix: $prefix');
      // ignore: avoid_print
      print('Asset prefix: $prefix');
      debugPrint('All grade files (${allForGrade.length}): ${allForGrade.join(', ')}');
      // ignore: avoid_print
      print('All grade files (${allForGrade.length}): ${allForGrade.join(', ')}');

      final matches = assets
          .where((path) => path.startsWith(prefix))
          .where((path) => path.endsWith('.txt'))
          .where((path) {
            final fileName = path.split('/').last;
            // Match by taskKey prefix, e.g. add_sub -> add_sub.txt / add_sub_02.txt.
            return fileName.startsWith(taskKey);
          })
          .toList()
        ..sort();
      debugPrint('Matched files (${matches.length}): ${matches.join(', ')}');
      // ignore: avoid_print
      print('Matched files (${matches.length}): ${matches.join(', ')}');

      if (matches.isEmpty) {
        final fallback = '$prefix$taskKey.txt';
        // If exact file exists, add it even if prefix matching failed.
        if (assets.contains(fallback)) {
          matches.add(fallback);
        }
        if (matches.isEmpty) {
          // If still empty, report all available files for this grade.
          debugPrint(
            'No questions found for g$grade/$taskKey. Available: ${allForGrade.join(', ')}',
          );
          // ignore: avoid_print
          print('No questions found for g$grade/$taskKey. Available: ${allForGrade.join(', ')}');
        }
      }

      final questions = <Question>[];
      for (final path in matches) {
        final raw = await rootBundle.loadString(path);
        final lines = raw.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty);
        var index = 0;
        for (final line in lines) {
          final id = '${path.split('/').last}-$index';
          questions.add(_parser.parse(id: id, raw: line, sourceName: path));
          index++;
        }
      }
      return questions;
    } catch (e, s) {
      // ignore: avoid_print
      print('Failed to load AssetManifest: $e');
      // ignore: avoid_print
      print(s);
      return const <Question>[];
    }
  }

  Future<List<int>> availableGrades() async {
    if (!useGradeSubdirectory) return const <int>[];
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    final base = assetBasePath.endsWith('/')
        ? assetBasePath.substring(0, assetBasePath.length - 1)
        : assetBasePath;
    final prefix = '$base/';
    final grades = <int>{};
    final regex = RegExp('^${RegExp.escape(prefix)}g(\\d+)/');
    for (final path in assets) {
      if (!path.startsWith(prefix)) continue;
      final match = regex.firstMatch(path);
      if (match == null) continue;
      final grade = int.tryParse(match.group(1) ?? '');
      if (grade != null) {
        grades.add(grade);
      }
    }
    final sorted = grades.toList()..sort();
    return sorted;
  }
}
