import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/time_entry.dart';
import '../widgets/time_entries_calendar.dart';
import '../models/report.dart';
import '../providers/report_provider.dart';
import '../providers/time_entries_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Ausgewählter Zeitraum (diese Woche, letzter Monat, etc.)
  String selectedPeriod = 'Diese Woche';

  // Leere Liste für generierte Rapporte
  final List<Report> generatedReports = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reports = context.watch<ReportProvider>().reports;
    
    // Berechne das Datum basierend auf der Auswahl
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;
    int weekNumber;

    switch (selectedPeriod) {
      case 'Diese Woche':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
        weekNumber = now.weekOfYear;
        break;
      case 'Letzte Woche':
        startDate = now.subtract(Duration(days: now.weekday + 6));
        endDate = startDate.add(const Duration(days: 6));
        weekNumber = startDate.weekOfYear;
        break;
      case 'Dieser Monat':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        weekNumber = now.weekOfYear;
        break;
      case 'Letzter Monat':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        weekNumber = startDate.weekOfYear;
        break;
      default:
        startDate = now;
        endDate = now;
        weekNumber = now.weekOfYear;
    }
    
    return SafeArea(
      child: Column(
        children: [
          // Zeitraum-Auswahl
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriod,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: const Color(0xFF1c2331),
                items: [
                  'Diese Woche',
                  'Letzte Woche',
                  'Dieser Monat',
                  'Letzter Monat',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPeriod = newValue!;
                  });
                },
              ),
            ),
          ),

          // Neue Datumsanzeige
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, 
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd.MM.', 'de').format(startDate)} - ${DateFormat('dd.MM.yyyy', 'de').format(endDate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'KW $weekNumber',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zusammenfassung
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Gesamtarbeitszeit',
                  _calculateStats()['totalTime'],
                  icon: Icons.access_time,
                  iconColor: theme.colorScheme.primary,
                ),
                const Divider(height: 24, color: Colors.white10),
                _buildSummaryRow(
                  'Pausenzeit',
                  _calculateStats()['pauseTime'],
                  icon: Icons.coffee,
                  iconColor: Colors.orange,
                ),
                const Divider(height: 24, color: Colors.white10),
                _buildSummaryRow(
                  'Durchschnitt/Tag',
                  '${_calculateStats()['avgPerDay']} h',
                  icon: Icons.trending_up,
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rapport-Generator Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showGenerateReportDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_download, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Rapport generieren',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Letzte Rapporte Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Letzte Rapporte',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'PDF Format',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste der letzten Rapporte
          Expanded(
            child: reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Rapporte generiert',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.white.withOpacity(0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            _showReportDetails(report);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'KW ${report.weekNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatHours(report.totalHours, report.totalMinutes),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.download,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showGenerateReportDialog() {
    DateTime selectedWeek = DateTime.now();
    int totalHours = 0;
    int totalMinutes = 0;
    bool reportExists = false;

    // Prüfe ob bereits ein Rapport existiert
    bool checkReportExists(DateTime week) {
      final weekNumber = week.weekOfYear;
      final year = week.year;
      return generatedReports.any((report) => 
        report.weekNumber == weekNumber && report.year == year
      );
    }

    // Berechne die Stunden für die ausgewählte Woche
    void calculateHours(DateTime week) {
      final startOfWeek = week.subtract(Duration(days: week.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      int totalSeconds = 0;
      
      for (var date = startOfWeek; date.isBefore(endOfWeek.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        final entries = kEvents[date] ?? [];
        for (var entry in entries) {
          final duration = entry.endTime.difference(entry.startTime);
          totalSeconds += duration.inSeconds - (entry.pauseMinutes * 60);
        }
      }
      
      totalHours = totalSeconds ~/ 3600;
      totalMinutes = (totalSeconds % 3600) ~/ 60;
      reportExists = checkReportExists(week);
    }

    calculateHours(selectedWeek);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1c2331),
          title: const Text(
            'Rapport generieren',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wählen Sie die Kalenderwoche:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              // Wochenauswahl
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          selectedWeek = selectedWeek.subtract(const Duration(days: 7));
                          calculateHours(selectedWeek);
                        });
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          'KW ${selectedWeek.weekOfYear}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd.MM.yyyy', 'de').format(selectedWeek),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          selectedWeek = selectedWeek.add(const Duration(days: 7));
                          calculateHours(selectedWeek);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stunden Zusammenfassung mit Warnung
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: (totalHours < 20 || reportExists)
                      ? Border.all(
                          color: Colors.orange.withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: (totalHours < 20)
                              ? Colors.orange
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gesamtarbeitszeit',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _formatHours(totalHours, totalMinutes),
                              style: TextStyle(
                                color: totalHours < 20 ? Colors.orange : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (totalHours < 20) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Weniger als 20 Stunden in dieser Woche',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (reportExists) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Für diese Woche existiert bereits ein Rapport',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: (totalHours > 0 || totalMinutes > 0) && !reportExists
                  ? () {
                      if (totalHours < 20) {
                        // Zeige Bestätigungsdialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1c2331),
                            title: const Text(
                              'Warnung',
                              style: TextStyle(color: Colors.orange),
                            ),
                            content: const Text(
                              'Die Arbeitszeit beträgt weniger als 20 Stunden. Möchten Sie den Rapport trotzdem generieren?',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Abbrechen'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context); // Schließe Warnung
                                  Navigator.pop(context); // Schließe Generator
                                  _generateReport(selectedWeek, totalHours, totalMinutes);
                                },
                                child: const Text('Generieren'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        _generateReport(selectedWeek, totalHours, totalMinutes);
                      }
                    }
                  : null,
              child: const Text('Generieren'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport(DateTime week, int totalHours, int totalMinutes) {
    final report = Report(
      weekNumber: week.weekOfYear,
      year: week.year,
      generatedAt: DateTime.now(),
      pdfPath: 'rapport_kw${week.weekOfYear}_${week.year}',
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      isSigned: false,
      isSent: false,
    );

    context.read<ReportProvider>().addReport(report);
    _showReportDetails(report);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapport wurde generiert')),
    );
  }

  // Neue Methode zum Anzeigen der Report-Details
  void _showReportDetails(Report report) {
    // Hole die Einträge vom Provider statt kEvents zu verwenden
    final timeEntriesProvider = context.read<TimeEntriesProvider>();
    
    // Berechne Start- und Enddatum der Woche
    final startOfWeek = DateTime(report.year, 1, 1)
        .add(Duration(days: (report.weekNumber - 1) * 7));
    final days = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1c2331),
        title: Row(
          children: [
            Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Rapport KW ${report.weekNumber}/${report.year}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gesamtarbeitszeit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gesamtarbeitszeit',
                        style: TextStyle(color: Colors.white70)),
                      Text(
                        _formatHours(report.totalHours, report.totalMinutes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tagesübersicht - Einträge vom Provider holen
            ...days.map((day) {
              final entries = timeEntriesProvider.getEntriesForDay(day);
              final dayTotal = entries.fold(Duration.zero, (total, entry) {
                return total + entry.endTime.difference(entry.startTime) - 
                       Duration(minutes: entry.pauseMinutes);
              });
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE', 'de').format(day),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      entries.isEmpty ? '-' : 
                      '${(dayTotal.inHours).toString().padLeft(2, '0')}:${((dayTotal.inMinutes % 60)).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Status-Anzeige
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  report.isSigned ? Icons.check_circle : Icons.circle_outlined,
                  color: report.isSigned ? Colors.green : Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Signiert',
                  style: TextStyle(
                    color: report.isSigned ? Colors.green : Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  report.isSent ? Icons.check_circle : Icons.circle_outlined,
                  color: report.isSent ? Colors.orange : Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Versendet',
                  style: TextStyle(
                    color: report.isSent ? Colors.orange : Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Buttons nebeneinander ohne Container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    report.isSigned ? Icons.check : Icons.draw,
                    color: Colors.white,
                  ),
                  label: Text(report.isSigned ? 'Signiert' : 'Signieren'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: report.isSigned 
                        ? Colors.green.withOpacity(0.5) 
                        : Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: report.isSigned ? null : () {
                    final updatedReport = report.copyWith(isSigned: true);
                    context.read<ReportProvider>().updateReportStatus(report, isSigned: true);
                    Navigator.pop(context);
                    _showReportDetails(updatedReport);
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    report.isSent ? Icons.check : Icons.send,
                    color: Colors.white,
                  ),
                  label: Text(report.isSent ? 'Versendet' : 'Versenden'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: report.isSent 
                        ? Colors.orange.withOpacity(0.5) 
                        : Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: report.isSent ? null : () {
                    final updatedReport = report.copyWith(isSent: true);
                    context.read<ReportProvider>().updateReportStatus(report, isSent: true);
                    Navigator.pop(context);
                    _showReportDetails(updatedReport);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  // Berechne die Statistiken für den ausgewählten Zeitraum
  Map<String, dynamic> _calculateStats() {
    DateTime startDate;
    DateTime endDate;
    final now = DateTime.now();

    // Zeitraum bestimmen
    switch (selectedPeriod) {
      case 'Diese Woche':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'Letzte Woche':
        startDate = now.subtract(Duration(days: now.weekday + 6));
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'Dieser Monat':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Letzter Monat':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      default:
        startDate = now;
        endDate = now;
    }

    int totalWorkSeconds = 0;
    int totalPauseMinutes = 0;
    int workDays = 0;
    
    // Alle Einträge im Zeitraum durchgehen
    for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final entries = kEvents[date] ?? [];
      if (entries.isNotEmpty) workDays++;
      
      for (var entry in entries) {
        final duration = entry.endTime.difference(entry.startTime);
        totalWorkSeconds += duration.inSeconds - (entry.pauseMinutes * 60);
        totalPauseMinutes += entry.pauseMinutes;
      }
    }

    final totalHours = totalWorkSeconds ~/ 3600;
    final totalMinutes = (totalWorkSeconds % 3600) ~/ 60;
    final pauseHours = totalPauseMinutes ~/ 60;
    final pauseMinutes = totalPauseMinutes % 60;
    
    final avgHoursPerDay = workDays > 0 
        ? (totalWorkSeconds / workDays / 3600).toStringAsFixed(1)
        : '0.0';

    return {
      'totalTime': _formatHours(totalHours, totalMinutes),
      'pauseTime': _formatHours(pauseHours, pauseMinutes),
      'avgPerDay': '${avgHoursPerDay}h',
    };
  }

  // Hilfsmethode für einheitliches Stundenformat
  String _formatHours(int hours, int minutes) {
    final totalHours = hours + (minutes / 60);
    return '${totalHours.toStringAsFixed(1)}h';
  }
}

// Hilfsmethode für Kalenderwoche
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysOffset = (7 - firstDayOfYear.weekday) % 7;
    final firstWeekday = firstDayOfYear.add(Duration(days: daysOffset));
    final diffInDays = difference(firstWeekday).inDays;
    final weekNumber = (diffInDays / 7).floor() + 1;
    return weekNumber;
  }
} 