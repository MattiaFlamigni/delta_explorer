/// Returns formatted string of the current date and time
String getFormattedDateTime() {
  final now = DateTime.now();
  final dayOfWeek =
      ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][now.weekday % 7];
  final month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ][now.month - 1];
  final day = now.day;
  final year = now.year;
  final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final minute = now.minute.toString().padLeft(2, '0');
  final period = now.hour >= 12 ? 'PM' : 'AM';

  return "$dayOfWeek, $month $day, $year, $hour:$minute $period";
}

/// Returns time duration (in seconds) to a min:sec format
String getformatTime(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
