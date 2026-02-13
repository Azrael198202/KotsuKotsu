part of 'quiz_screen.dart';

extension _QuizScreenInput on _QuizScreenState {
  Widget _buildInputPanel() {
    return Column(
      children: [
        SegmentedButton<InputMode>(
          segments: [
            ButtonSegment(
              value: InputMode.keypad,
              label: Text('キー入力'),
              icon: Icon(Icons.dialpad),
            ),
            ButtonSegment(
              value: InputMode.handwriting,
              label: Text('手書き'),
              icon: Icon(Icons.draw),
              enabled: _started,
            ),
          ],
          selected: {_inputMode == InputMode.system ? InputMode.keypad : _inputMode},
          onSelectionChanged: (value) {
            if (value.first == InputMode.handwriting && !_started) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('手書きは かいしご に つかえます')),
              );
              return;
            }
            _safeSetState(() {
              _inputMode = value.first;
            });
          },
        ),
        const SizedBox(height: 14),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _inputMode == InputMode.handwriting
                ? _buildHandwritingPad()
                : _buildKeypad(),
          ),
        ),
      ],
    );
  }

  Widget _buildInputPanelShell() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _inputPanelCollapsed ? 52 : 300,
      constraints: _inputPanelCollapsed
          ? const BoxConstraints.tightFor(width: 64, height: 84)
          : const BoxConstraints.tightFor(width: 300, height: 560),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'とじる',
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
    final panelWidth = _inputPanelCollapsed ? 64.0 : 300.0;
    final panelHeight = _inputPanelCollapsed ? 84.0 : 560.0;
    final double maxX =
        (constraints.maxWidth - panelWidth).clamp(0.0, constraints.maxWidth).toDouble();
    final double maxY =
        (constraints.maxHeight - panelHeight).clamp(0.0, constraints.maxHeight).toDouble();
    if (!_floatingInitialized) {
      _floatingPanelOffset = Offset(maxX, maxY / 2);
      _floatingInitialized = true;
    }
    final clamped = Offset(
      _floatingPanelOffset.dx.clamp(0.0, maxX).toDouble(),
      _floatingPanelOffset.dy.clamp(0.0, maxY).toDouble(),
    );
    if (clamped != _floatingPanelOffset) {
      _floatingPanelOffset = clamped;
    }
    return Positioned(
      left: _floatingPanelOffset.dx,
      top: _floatingPanelOffset.dy,
      child: GestureDetector(
        onPanUpdate: (_inputMode == InputMode.handwriting && !_inputPanelCollapsed)
            ? null
            : (details) {
                _safeSetState(() {
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
            tooltip: 'ひらく',
            onPressed: _toggleInputPanel,
            icon: const Icon(Icons.pan_tool_alt, color: Color(0xFFF9A825), size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDigitRow(const ['1', '2', '3']),
          const SizedBox(height: 14),
          _buildDigitRow(const ['4', '5', '6']),
          const SizedBox(height: 14),
          _buildDigitRow(const ['7', '8', '9']),
          const SizedBox(height: 14),
          Row(
            children: [
              const Spacer(),
              _buildDigitButton('0'),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'けす',
                  background: const Color(0xFFFFE082),
                  foreground: const Color(0xFFB86A35),
                  onTap: _clearActiveInput,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionButton(
                  label: 'OK',
                  background: const Color(0xFF74C7E8),
                  foreground: Colors.white,
                  onTap: _onOkPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitRow(List<String> values) {
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          Expanded(child: _buildDigitButton(values[i])),
          if (i < values.length - 1) const SizedBox(width: 18),
        ],
      ],
    );
  }

  Widget _buildDigitButton(String value) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: () => _handleKeyPress(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEFF3E8),
          foregroundColor: const Color(0xFF708A67),
          elevation: 1,
          shadowColor: const Color(0x33000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD6DEC9)),
          ),
        ),
        child: AutoSizeText(
          value,
          maxLines: 1,
          minFontSize: 16,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: foreground.withValues(alpha: 0.2)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  void _onOkPressed() {
    if (_activeIndex < 0 || _activeIndex >= _controllers.length) return;
    final next = _activeIndex + 1;
    if (next < _controllers.length) {
      _setActiveIndex(next);
    } else {
      _focusNodes[_activeIndex].unfocus();
    }
  }

  Widget _buildHandwritingPad() {
    if (!_started) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDFE7F2)),
        ),
        child: const Center(
          child: Text(
            '先に「開始」をおしてから 手書きをつかってください',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF607D8B)),
          ),
        ),
      );
    }
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
            'てがき メモ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Expanded(child: _ScratchPad()),
          const SizedBox(height: 8),
          const Text(
            '※ こたえ は した の らんに にゅうりょく してください',
            style: TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
          ),
        ],
      ),
    );
  }
}
