import 'package:flutter/material.dart';

/// Widget that represents action button with icon and label
class ActionButton extends StatelessWidget {
  /// Icondata
  final IconData icon;

  /// Text label for button
  final String label;

  /// Callback function for button press
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
