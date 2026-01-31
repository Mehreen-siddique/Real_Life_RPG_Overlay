class DailyHealthData {
  final DateTime date;
  final int steps;
  final double distanceKm;
  final double calories;
  final int activeMinutes;

  DailyHealthData({
    required this.date,
    this.steps = 0,
    this.distanceKm = 0.0,
    this.calories = 0.0,
    this.activeMinutes = 0,
  });

  String get dayLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String get dateLabel =>
      '${date.month}/${date.day}';
}
