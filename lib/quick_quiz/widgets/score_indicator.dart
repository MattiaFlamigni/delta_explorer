import 'package:flutter/material.dart';
import 'dart:math';

/// Painter class to draw circular indicator based on accuracy
class ScoreIndicator extends CustomPainter {
  /// Accuracy percentage of a quiz
  final int accuracy;

  /// Constructor
  ScoreIndicator({required this.accuracy});

  @override
  void paint(Canvas canvas, Size size) {
    /// Start angle for a indicator
    double startAngle = 130 * pi / 180;

    /// Sweep angle for a  background arc
    double sweepAngle = 280 * pi / 180;

    /// Sweep angle calculated based on the accuracy score
    double scoreSweepAngle = accuracy * (280 / 100) * pi / 180;

    /// Paint object for drawing background arc
    Paint circularPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    /// Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      startAngle,
      sweepAngle,
      false,
      circularPaint,
    );

    /// Paint progress arc using gradient colors
    Paint progressPaint = Paint()
      ..shader = const LinearGradient(colors: [Colors.blue, Colors.purple])
          .createShader(
        Rect.fromCircle(
            center: size.center(Offset.zero), radius: size.width / 2),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    /// Draw progress
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      startAngle,
      scoreSweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
