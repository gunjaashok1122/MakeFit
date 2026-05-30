import 'dart:math';
import 'package:flutter/material';
import '../themes/app_theme.dart';

class ProgressRing extends StatefulWidget {
  final double percentage; // 0.0 to 1.0
  final String valueText;
  final String labelText;
  final double size;
  final double strokeWidth;
  final Gradient? activeGradient;
  final Color trackColor;

  const ProgressRing({
    Key? key,
    required this.percentage,
    required this.valueText,
    required this.labelText,
    this.size = 140.0,
    this.strokeWidth = 12.0,
    this.activeGradient,
    this.trackColor = AppTheme.cardNavyLight,
  }) : super(key: key);

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.activeGradient ??
        const LinearGradient(
          colors: [AppTheme.deepPurple, AppTheme.neonPurple, AppTheme.neonPink],
        );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  percentage: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  activeGradient: gradient,
                  trackColor: widget.trackColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.valueText,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.labelText,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: widget.size * 0.08,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Gradient activeGradient;
  final Color trackColor;

  _RingPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.activeGradient,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw active glowing ring
    if (percentage > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      const startAngle = -pi / 2;
      final sweepAngle = 2 * pi * percentage.clamp(0.0, 1.0);

      // Create glowing shader
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = activeGradient.createShader(rect);

      // Draw shadow glow path (thicker and blurred, under the active line)
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4.0
        ..strokeCap = StrokeCap.round
        ..shader = activeGradient.createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor;
  }
}
