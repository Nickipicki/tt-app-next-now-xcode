import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import 'time_entry_dialog.dart';

// Hilfsfunktion für Beispieldaten
DateTime _dateTime(int hour, [int addDays = 0]) {
  final date = DateTime.now().add(Duration(days: addDays));
  return DateTime(date.year, date.month, date.day, hour);
}

// Beispiel-Daten
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

// Mache kEvents öffentlich verfügbar
final kEvents = LinkedHashMap<DateTime, List<TimeEntry>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll({
    kToday: [
      TimeEntry(
        location: 'Büro München',
        startTime: _dateTime(9),
        endTime: _dateTime(12),
        pauseMinutes: 15,
      ),
      TimeEntry(
        location: 'Home Office',
        startTime: _dateTime(13),
        endTime: _dateTime(17),
        pauseMinutes: 30,
      ),
    ],
    kToday.subtract(const Duration(days: 1)): [
      TimeEntry(
        location: 'Projekt Alpha',
        startTime: _dateTime(8, -1),
        endTime: _dateTime(16, -1),
        pauseMinutes: 45,
      ),
    ],
    kToday.subtract(const Duration(days: 2)): [
      TimeEntry(
        location: 'Projekt Gamma',
        startTime: _dateTime(9, -2),
        endTime: _dateTime(17, -2),
        pauseMinutes: 30,
      ),
    ],
  });

class TimeEntriesCalendar extends StatefulWidget {
  const TimeEntriesCalendar({super.key});

  @override
  State<TimeEntriesCalendar> createState() => _TimeEntriesCalendarState();
}

class _TimeEntriesCalendarState extends State<TimeEntriesCalendar> {
  late final ValueNotifier<List<TimeEntry>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<TimeEntry> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<TimeEntry>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: const TextStyle(
                color: Colors.white,
              ),
              weekendTextStyle: const TextStyle(
                color: Colors.white70,
              ),
              outsideTextStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
              markersMaxCount: 1,
              markerSize: 6,
              markerMargin: const EdgeInsets.only(top: 6),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 5,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<TimeEntry>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(event.location),
                        subtitle: Text(
                          '${DateFormat('HH:mm').format(event.startTime)} - '
                          '${DateFormat('HH:mm').format(event.endTime)}\n'
                          'Pause: ${event.pauseMinutes} min',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(event),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => TimeEntryDialog(
        selectedDate: _selectedDay!,
      ),
    ).then((entry) {
      if (entry != null) {
        setState(() {
          final entries = kEvents[_selectedDay!] ?? [];
          kEvents[_selectedDay!] = [...entries, entry];
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      }
    });
  }

  void _showEditDialog(TimeEntry event) {
    showDialog(
      context: context,
      builder: (context) => TimeEntryDialog(
        selectedDate: _selectedDay!,
        entry: event,
      ),
    ).then((entry) {
      if (entry != null) {
        setState(() {
          final entries = kEvents[_selectedDay!] ?? [];
          final index = entries.indexOf(event);
          if (index != -1) {
            entries[index] = entry;
            kEvents[_selectedDay!] = entries;
            _selectedEvents.value = _getEventsForDay(_selectedDay!);
          }
        });
      }
    });
  }

  void _showDeleteDialog(TimeEntry event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: const Text('Möchten Sie diesen Eintrag wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                final entries = kEvents[_selectedDay!] ?? [];
                entries.remove(event);
                if (entries.isEmpty) {
                  kEvents.remove(_selectedDay!);
                } else {
                  kEvents[_selectedDay!] = entries;
                }
                _selectedEvents.value = _getEventsForDay(_selectedDay!);
              });
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
} 