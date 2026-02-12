part of 'quiz_screen.dart';

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onPressed : null,
      radius: 22,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
      ),
    );
  }
}

class _MathPrompt extends StatelessWidget {
  const _MathPrompt({required this.expression});

  final String expression;

  @override
  Widget build(BuildContext context) {
    if (expression.isEmpty) {
      return const Text('式が読み取れません');
    }
    return AutoSizeText(
      expression,
      maxLines: 1,
      minFontSize: 18,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({
    required this.child,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _PaperLinePainter(),
        child: child,
      ),
    );
  }
}

class _PaperLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAF1F7)
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperLinePainter oldDelegate) => false;
}

class LongDivisionBracket extends StatelessWidget {
  const LongDivisionBracket({
    super.key,
    required this.width,
    required this.height,
    this.strokeWidth = 2,
    this.color = Colors.black,
    this.radius = 6,
    this.topLineOffset = 6,
    this.topLineInset = 0,
    this.leftLineInset = 0,
  });

  final double width;
  final double height;
  final double strokeWidth;
  final Color color;
  final double radius;
  final double topLineOffset;
  final double topLineInset;
  final double leftLineInset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _LongDivisionBracketPainter(
        strokeWidth: strokeWidth,
        color: color,
        radius: radius,
        topLineOffset: topLineOffset,
        topLineInset: topLineInset,
        leftLineInset: leftLineInset,
      ),
    );
  }
}

class _LongDivisionBracketPainter extends CustomPainter {
  _LongDivisionBracketPainter({
    required this.strokeWidth,
    required this.color,
    required this.radius,
    required this.topLineOffset,
    required this.topLineInset,
    required this.leftLineInset,
  });

  final double strokeWidth;
  final Color color;
  final double radius;
  final double topLineOffset;
  final double topLineInset;
  final double leftLineInset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final double r = radius.clamp(0.0, size.shortestSide / 2).toDouble();
    final double y0 = topLineOffset.clamp(0.0, size.height);
    final path = Path();
    path.moveTo(0, y0 + r + leftLineInset);
    path.moveTo(0, y0 + r);
    path.arcToPoint(
      Offset(r, y0),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.lineTo(size.width + topLineInset, y0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LongDivisionBracketPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.topLineOffset != topLineOffset ||
        oldDelegate.topLineInset != topLineInset ||
        oldDelegate.leftLineInset != leftLineInset;
  }
}

class _ScratchPad extends StatefulWidget {
  const _ScratchPad({this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<_ScratchPad> createState() => _ScratchPadState();
}

class _ScratchPadState extends State<_ScratchPad> {
  final List<Offset?> _points = <Offset?>[];

  void _clear() {
    setState(_points.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E6EF)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.globalPosition);
                setState(() => _points.add(local));
              },
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.globalPosition);
                setState(() => _points.add(local));
              },
              onPanEnd: (_) => setState(() => _points.add(null)),
              child: CustomPaint(
                painter: _ScratchPainter(points: _points),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: _clear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE0E6EF)),
                ),
                child: const Text(
                  '消去',
                  style: TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  _ScratchPainter({required this.points});

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A3B4C)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
