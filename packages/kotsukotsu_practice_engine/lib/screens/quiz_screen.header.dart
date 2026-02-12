part of 'quiz_screen.dart';

extension _QuizScreenHeader on _QuizScreenState {
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
              Text('制限時間: ${config.timeLimitSeconds}s'),
              const SizedBox(height: 6),
              Text('合格点: ${config.passScore}'),
            ],
          ),
          const Spacer(),
          _buildHeaderClock(),
          const Spacer(),
          if (!_inQuestionPhase)
            FilledButton(
              onPressed: _goToHomework,
              child: const Text('宿題へ'),
            )
          else if (!_started)
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
}
