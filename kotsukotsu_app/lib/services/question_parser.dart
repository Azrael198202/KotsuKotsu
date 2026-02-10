import '../models/question.dart';
import '../models/question_type.dart';

class QuestionParser {
  Question parse({
    required String id,
    required String raw,
    String? sourceName,
  }) {
    var cleaned = raw.trim();
    if (!cleaned.startsWith('[WORD]') && cleaned.contains('|')) {
      cleaned = cleaned.split('|').first.trim();
    }
    cleaned = cleaned
        .replaceAll('\uFF83\u30FB', 'x')
        .replaceAll('\uFF83\uFF77', '/')
        .replaceAll('\u00D7', 'x')
        .replaceAll('\u00F7', '/');
    final type = _resolveType(cleaned, sourceName);
    String? expectedAnswer;
    if (type == QuestionType.word) {
      final parsed = _parseWordWithAnswer(cleaned);
      cleaned = parsed.text;
      expectedAnswer = parsed.answer;
    } else {
      expectedAnswer = _tryComputeAnswer(cleaned, type);
    }
    return Question(id: id, raw: cleaned, type: type, expectedAnswer: expectedAnswer);
  }

  QuestionType _resolveType(String raw, String? sourceName) {
    final fromName = _typeFromFileName(sourceName ?? '');
    if (fromName != QuestionType.unknown) {
      return fromName;
    }
    return _typeFromContent(raw);
  }

  QuestionType _typeFromFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('word')) return QuestionType.word;
    if (lower.contains('fractions')) return QuestionType.fraction;
    if (lower.contains('ratio')) return QuestionType.ratio;
    if (lower.contains('decimals')) return QuestionType.decimal;
    if (lower.contains('div_long') || lower.contains('div_column')) {
      return QuestionType.divideLong;
    }
    if (lower.contains('mul_column')) return QuestionType.multiplyColumn;
    if (lower.contains('add_sub_column')) return QuestionType.addSubColumn;
    if (lower.contains('mul') || lower.contains('multiply')) {
      return QuestionType.multiply;
    }
    if (lower.contains('div') || lower.contains('divide')) return QuestionType.divide;
    if (lower.contains('add') || lower.contains('sub')) return QuestionType.addSub;
    return QuestionType.unknown;
  }

  QuestionType _typeFromContent(String raw) {
    if (raw.startsWith('[WORD]')) return QuestionType.word;
    if (raw.contains(':')) return QuestionType.ratio;
    if (_hasFraction(raw)) return QuestionType.fraction;
    if (raw.contains('.')) return QuestionType.decimal;
    if (raw.contains('/')) return QuestionType.divide;
    if (raw.contains('x') || raw.contains('*')) return QuestionType.multiply;
    if (raw.contains('+') || raw.contains('-')) return QuestionType.addSub;
    return QuestionType.unknown;
  }

  bool _hasFraction(String raw) {
    final fractionPattern = RegExp(r'\\d+\\s*/\\s*\\d+');
    return fractionPattern.hasMatch(raw);
  }

  String? _tryComputeAnswer(String raw, QuestionType type) {
    if (type == QuestionType.word || type == QuestionType.unknown) {
      return null;
    }

    final normalized = raw.replaceAll('x', '*');
    if (type == QuestionType.fraction) {
      return _solveFraction(normalized);
    }
    if (type == QuestionType.ratio) {
      return _solveRatio(normalized);
    }

    final match = RegExp(r'^\s*(-?\d+(?:\.\d+)?)\s*([+\-*/])\s*(-?\d+(?:\.\d+)?)\s*=?\s*$')
        .firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final left = double.parse(match.group(1)!);
    final op = match.group(2)!;
    final right = double.parse(match.group(3)!);
    switch (op) {
      case '+':
        return _formatNumber(left + right);
      case '-':
        return _formatNumber(left - right);
      case '*':
        return _formatNumber(left * right);
      case '/':
        if (_isInteger(left) && _isInteger(right) && right != 0) {
          final intLeft = left.toInt();
          final intRight = right.toInt();
          final quotient = intLeft ~/ intRight;
          final remainder = intLeft % intRight;
          return remainder == 0 ? '$quotient' : '$quotient r$remainder';
        }
        return right == 0 ? null : _formatNumber(left / right);
    }
    return null;
  }

  String _solveRatio(String normalized) {
    final match = RegExp(r'^\s*(\d+)\s*:\s*(\d+)\s*$').firstMatch(normalized);
    if (match == null) return '';
    final left = int.parse(match.group(1)!);
    final right = int.parse(match.group(2)!);
    if (right == 0) return '';
    final gcd = _gcd(left.abs(), right.abs());
    return '${left ~/ gcd}:${right ~/ gcd}';
  }

  String _solveFraction(String normalized) {
    final match = RegExp(r'^(\d+)\s*/\s*(\d+)\s*([+\-*/])\s*(\d+)\s*/\s*(\d+)\s*=?\s*$')
        .firstMatch(normalized);
    if (match == null) {
      return '';
    }
    final a = int.parse(match.group(1)!);
    final b = int.parse(match.group(2)!);
    final op = match.group(3)!;
    final c = int.parse(match.group(4)!);
    final d = int.parse(match.group(5)!);

    int num;
    int den;
    switch (op) {
      case '+':
        num = a * d + c * b;
        den = b * d;
        break;
      case '-':
        num = a * d - c * b;
        den = b * d;
        break;
      case '*':
        num = a * c;
        den = b * d;
        break;
      case '/':
        num = a * d;
        den = b * c;
        break;
      default:
        return '';
    }
    final gcd = _gcd(num.abs(), den.abs());
    return '${num ~/ gcd}/${den ~/ gcd}';
  }

  String _formatNumber(double value) {
    if (_isInteger(value)) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+\$'), '').replaceFirst(RegExp(r'\\.\$'), '');
  }

  bool _isInteger(double value) => value % 1 == 0;

  int _gcd(int a, int b) {
    var x = a;
    var y = b;
    while (y != 0) {
      final temp = y;
      y = x % y;
      x = temp;
    }
    return x;
  }

  _WordParseResult _parseWordWithAnswer(String raw) {
    if (!raw.contains('|')) {
      return _WordParseResult(text: raw, answer: null);
    }
    final parts = raw.split('|');
    final text = parts.first.trim();
    final answer = parts.sublist(1).join('|').trim();
    return _WordParseResult(text: text, answer: answer.isEmpty ? null : answer);
  }
}

class _WordParseResult {
  const _WordParseResult({required this.text, required this.answer});

  final String text;
  final String? answer;
}
