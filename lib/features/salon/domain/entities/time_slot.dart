class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool available;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  String get formattedTime {
    final h = startTime.hour.toString().padLeft(2, '0');
    final m = startTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
