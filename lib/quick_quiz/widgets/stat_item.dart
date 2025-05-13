import 'package:flutter/material.dart';

/// Widget showing the score of the quiz
class ScoreLabel extends StatelessWidget {
  /// Icon data
  final IconData icon;

  /// Label of the score
  final String label;

  /// Actual score
  final String value;

  /// Constructor
  const ScoreLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2)
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
