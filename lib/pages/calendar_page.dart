import 'package:flutter/material.dart';
import '../widgets/time_entries_calendar.dart';
import '../widgets/week_view.dart';
import '../models/time_entry.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _showWeekView = true;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Nach rechts -> Wochenansicht
            setState(() => _showWeekView = true);
          } else if (details.primaryVelocity! < 0) {
            // Nach links -> Monatsansicht
            setState(() => _showWeekView = false);
          }
        },
        child: Column(
          children: [
            // Header mit Umschaltung zwischen Wochen- und Monatsansicht
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 32,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Animierter Hintergrund
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    left: _showWeekView ? 2 : null,
                    right: _showWeekView ? null : 2,
                    top: 2,
                    bottom: 2,
                    width: 86,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _showWeekView = true),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: _showWeekView 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.5),
                          ),
                          child: Text(
                            'Woche',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _showWeekView = false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: !_showWeekView 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.5),
                          ),
                          child: Text(
                            'Monat',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content mit Animation
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey<bool>(_showWeekView),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _showWeekView
                      ? WeekView(
                          selectedDate: _selectedDate,
                          entries: kEvents.entries
                              .expand((e) => e.value)
                              .toList(),
                          onDaySelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        )
                      : const TimeEntriesCalendar(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 