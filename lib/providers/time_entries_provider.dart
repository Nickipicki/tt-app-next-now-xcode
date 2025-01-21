import 'package:flutter/material.dart';
import '../models/time_entry.dart';
import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

class TimeEntriesProvider extends ChangeNotifier {
  final Map<DateTime, List<TimeEntry>> _entries = {};

  UnmodifiableMapView<DateTime, List<TimeEntry>> get entries => 
      UnmodifiableMapView(_entries);

  List<TimeEntry> getEntriesForDay(DateTime day) {
    return _entries[day] ?? [];
  }

  void addEntry(TimeEntry entry) {
    final date = DateTime(
      entry.startTime.year,
      entry.startTime.month,
      entry.startTime.day,
    );
    
    final entries = _entries[date] ?? [];
    _entries[date] = [...entries, entry];
    notifyListeners();
  }

  void updateEntry(DateTime date, TimeEntry oldEntry, TimeEntry newEntry) {
    final entries = _entries[date] ?? [];
    final index = entries.indexOf(oldEntry);
    if (index != -1) {
      entries[index] = newEntry;
      _entries[date] = entries;
      notifyListeners();
    }
  }

  void deleteEntry(DateTime date, TimeEntry entry) {
    final entries = _entries[date] ?? [];
    entries.remove(entry);
    if (entries.isEmpty) {
      _entries.remove(date);
    } else {
      _entries[date] = entries;
    }
    notifyListeners();
  }

  // Später für Datenbank-Integration
  Future<void> loadEntries() async {
    // TODO: Load from database
  }

  Future<void> saveEntries() async {
    // TODO: Save to database
  }
} 