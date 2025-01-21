import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/time_entry.dart';

class WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final List<TimeEntry> entries;
  final Function(DateTime)? onDaySelected;

  const WeekView({
    super.key,
    required this.selectedDate,
    required this.entries,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    // Filtern der Einträge für den ausgewählten Tag
    final selectedDayEntries = entries.where((entry) => 
      isSameDay(entry.startTime, selectedDate)
    ).toList();

    return Column(
      children: [
        // Wochentage Header - kompakter und klickbar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Row(
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = isSameDay(date, DateTime.now());
              final isSelected = isSameDay(date, selectedDate);
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Callback aufrufen wenn verfügbar
                    onDaySelected?.call(date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary.withOpacity(0.15)
                          : isToday 
                              ? Colors.white.withOpacity(0.05)
                              : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('E', 'de').format(date).substring(0, 2),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected || isToday
                                ? theme.colorScheme.primary
                                : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected || isToday
                                ? theme.colorScheme.primary
                                : Colors.white,
                            fontWeight: isSelected || isToday 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Titel für ausgewählten Tag
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text(
                DateFormat('EEEE, dd. MMMM', 'de').format(selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${selectedDayEntries.length} Einträge',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),

        // Einträge des ausgewählten Tages
        Expanded(
          child: selectedDayEntries.isEmpty
              ? Center(
                  child: Text(
                    'Keine Einträge für diesen Tag',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedDayEntries.length,
                  itemBuilder: (context, index) {
                    final entry = selectedDayEntries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.white.withOpacity(0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.location,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: theme.colorScheme.primary.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${DateFormat('HH:mm').format(entry.startTime)} - '
                                  '${DateFormat('HH:mm').format(entry.endTime)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.coffee,
                                  size: 16,
                                  color: theme.colorScheme.primary.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.pauseMinutes} min',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Neue Widget-Klasse für die Vorschau
class ReportPreview extends StatelessWidget {
  final Map<String, dynamic> reportData;
  
  const ReportPreview({required this.reportData, super.key});
  
  @override
  Widget build(BuildContext context) {
    // Minimale Vorschau zum Testen
    return Column(
      children: [
        Text('KW ${reportData['weekNumber']}'),
        Text('Datum: ${reportData['startDate']}'),
      ],
    );
  }
} 