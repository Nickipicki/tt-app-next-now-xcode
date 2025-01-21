import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';

class TimeEntryDialog extends StatefulWidget {
  final TimeEntry? entry;
  final DateTime selectedDate;

  const TimeEntryDialog({
    super.key,
    this.entry,
    required this.selectedDate,
  });

  @override
  State<TimeEntryDialog> createState() => _TimeEntryDialogState();
}

class _TimeEntryDialogState extends State<TimeEntryDialog> {
  late TextEditingController _locationController;
  late DateTime _startTime;
  late DateTime _endTime;
  late TextEditingController _pauseController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.entry?.location ?? '');
    _startTime = widget.entry?.startTime ?? 
        DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 8, 0);
    _endTime = widget.entry?.endTime ?? 
        DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 17, 0);
    _pauseController = TextEditingController(
        text: (widget.entry?.pauseMinutes ?? 30).toString());
  }

  @override
  void dispose() {
    _locationController.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.entry == null ? 'Neuer Eintrag' : 'Eintrag bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Ort/Kostenstelle',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_startTime),
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = DateTime(
                            _startTime.year,
                            _startTime.month,
                            _startTime.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.access_time, color: theme.colorScheme.primary),
                    label: Text(
                      'Start: ${DateFormat('HH:mm').format(_startTime)}',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_endTime),
                      );
                      if (time != null) {
                        setState(() {
                          _endTime = DateTime(
                            _endTime.year,
                            _endTime.month,
                            _endTime.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.access_time, color: theme.colorScheme.primary),
                    label: Text(
                      'Ende: ${DateFormat('HH:mm').format(_endTime)}',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pauseController,
              decoration: const InputDecoration(
                labelText: 'Pause (Minuten)',
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () {
            if (_locationController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bitte Ort/Kostenstelle eingeben')),
              );
              return;
            }
            final entry = TimeEntry(
              location: _locationController.text,
              startTime: _startTime,
              endTime: _endTime,
              pauseMinutes: int.tryParse(_pauseController.text) ?? 0,
            );
            Navigator.pop(context, entry);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
} 