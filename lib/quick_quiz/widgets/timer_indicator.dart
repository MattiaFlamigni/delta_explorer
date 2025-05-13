import 'package:flutter/material.dart';

class TimerIndicator extends StatefulWidget {
  /// Total time to indicate as an indicator
  final double totalTime;

  /// Primary color
  final Color primaryColor;

  /// Constructor
  const TimerIndicator({
    super.key,
    required this.totalTime,
    required this.primaryColor,
  });

  @override
  _TimerIndicatorState createState() => _TimerIndicatorState();
}

class _TimerIndicatorState extends State<TimerIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.totalTime.toInt(),
      ),
    )..addListener(() {
        setState(() {});
      });

    // Start the animation
    _animation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(TimerIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _animation.value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.primaryColor, // Use widget.primaryColor without const
            ),
            minHeight: 5.0,
          ),
        ),
      ],
    );
  }
}
