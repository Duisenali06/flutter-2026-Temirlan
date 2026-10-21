import '../models/workshop.dart';

const _months = [
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
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatClock(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatDateYear(DateTime d) => '${formatDate(d)} ${d.year}';

/// "18 Oct, 10:00"
String formatDateTime(DateTime d) =>
    '${formatDate(d)}, ${formatClock(d.hour, d.minute)}';

String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

/// R9: exhaustive switch over the sealed class.
String formatCountdown(Countdown c) => switch (c) {
      Upcoming(:final left) => 'In ${formatDuration(left)}',
      Started() => 'Started',
      Ended() => 'Ended',
    };
