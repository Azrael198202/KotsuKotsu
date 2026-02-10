part of 'quiz_screen.dart';

extension _QuizScreenQuestions on _QuizScreenState {
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
        const Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: _buildAnswerField(
            quotientIndex,
            hint: '商',
            keyboardType: TextInputType.number,
            enabled: _started,
          ),
        ),
        const SizedBox(width: 16),
        const Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: _buildAnswerField(
            remainderIndex,
            hint: '余',
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
        return _buildColumnQuestion(question, index, hint: '答え');
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
              const SizedBox(height: 4),
              SizedBox(
                width: answerWidth,
                child: const Divider(
                  height: 8,
                  thickness: 2,
                  color: Colors.black,
                ),
              ),
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
    final binding = _questionFields[index];
    final fieldIndex = binding.quotientIndex;
    final stepIndices = binding.indices;
    const style = TextStyle(fontFamily: 'monospace', fontSize: 26, height: 1.2);

    final divisorWidth = _textWidth(divisor, style);
    final dividendWidth = _textWidth(dividend, style);
    final textHeight = _textHeight(style);

    const answerBoxHeight = 56.0;
    final bracketWidth = (dividendWidth + 16).clamp(120.0, 320.0).toDouble();
    final bracketHeight = 60.0;
    final bracketTop = answerBoxHeight + 6.0;
    final bracketLeft = divisorWidth + 8.0;

    final divisorTop = bracketTop + (bracketHeight - textHeight) / 2 + 8;
    final dividendTop = divisorTop;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: bracketTop + bracketHeight + 70,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: bracketLeft,
                      top: bracketTop,
                      child: LongDivisionBracket(
                        width: bracketWidth,
                        height: bracketHeight,
                        strokeWidth: 2,
                        radius: 120,
                        topLineOffset: 8,
                        color: Colors.black,
                      ),
                    ),
                    Positioned(
                      left: 3,
                      top: divisorTop-5,
                      child: Text(
                        divisor,
                        style: style,
                      ),
                    ),
                    Positioned(
                      left: bracketLeft + 38,
                      top: dividendTop - 5,
                      child: Text(
                        dividend,
                        style: style,
                      ),
                    ),
                    Positioned(
                      left: bracketLeft + 28,
                      top: 0,
                      child: SizedBox(
                        width: bracketWidth - 20,
                        child: _buildAnswerField(
                          fieldIndex,
                          hint: '商',
                          enabled: _started,
                        ),
                      ),
                    ),
                    Positioned(
                      left: bracketLeft + bracketWidth + 12,
                      top: bracketTop + bracketHeight + 23,
                      child: SizedBox(
                        width: 90,
                        child: _buildAnswerField(
                          stepIndices.length > 1 ? stepIndices.last : fieldIndex,
                          hint: '余',
                          enabled: _started,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (stepIndices.length > 2) ...[
                const SizedBox(height: 12),
                for (var i = 1; i < stepIndices.length - 1; i++) ...[
                  SizedBox(
                    width: bracketWidth + bracketLeft,
                    child: _buildAnswerField(
                      stepIndices[i],
                      hint: 'Step',
                      enabled: _started,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
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
    return width.clamp(140.0, 260.0).toDouble();
  }

  double _textWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  double _textHeight(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.height;
  }
}
