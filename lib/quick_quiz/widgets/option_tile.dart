import 'package:flutter/material.dart';

/// Widget to display option
class OptionTile extends StatelessWidget {
  /// Number of the option
  final String serialNumber;

  /// Text of the option
  final String optionText;

  /// Boolean indicating if current option is selected or not
  final bool isSelected;

  /// Callback function triggered when tile is tapped
  final VoidCallback onTap;

  /// Primary color
  final Color primaryColor;

  /// Constructor
  const OptionTile(
      {super.key,
      required this.optionText,
      required this.isSelected,
      required this.onTap,
      required this.serialNumber,
      required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : const Color(0xffF7F7F7),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              margin: const EdgeInsets.only(right: 10),
              child: Text(
                serialNumber,
                style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black),
              ),
            ),
            Expanded(
              child: Text(optionText,
                  style: const TextStyle(fontSize: 15),
                  maxLines: null,
                  overflow: TextOverflow.visible),
            ),
          ],
        ),
      ),
    );
  }
}
