part of 'quiz_screen.dart';

extension _QuizScreenInput on _QuizScreenState {
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
            _safeSetState(() {
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
        onPanUpdate: (details) {
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
}
