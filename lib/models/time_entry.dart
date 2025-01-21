import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

class TimeEntry {
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int pauseMinutes;

  const TimeEntry({
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.pauseMinutes,
  });
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
} 