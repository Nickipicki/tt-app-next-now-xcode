import 'package:flutter/foundation.dart';
import '../models/report.dart';

class ReportProvider extends ChangeNotifier {
  final List<Report> _reports = [];

  List<Report> get reports => List.unmodifiable(_reports);

  void addReport(Report report) {
    final newReport = Report(
      weekNumber: report.weekNumber,
      year: report.year,
      generatedAt: report.generatedAt,
      pdfPath: report.pdfPath,
      totalHours: report.totalHours,
      totalMinutes: report.totalMinutes,
      isSigned: false,
      isSent: false,
    );
    
    _reports.add(newReport);
    notifyListeners();
  }

  void updateReport(Report report) {
    final index = _reports.indexWhere((r) => 
      r.weekNumber == report.weekNumber && r.year == report.year
    );
    if (index != -1) {
      _reports[index] = report;
      notifyListeners();
    }
  }

  void updateReportStatus(Report report, {bool? isSigned, bool? isSent}) {
    final index = _reports.indexWhere((r) => 
      r.weekNumber == report.weekNumber && r.year == report.year
    );
    if (index != -1) {
      _reports[index] = Report(
        weekNumber: report.weekNumber,
        year: report.year,
        generatedAt: report.generatedAt,
        pdfPath: report.pdfPath,
        totalHours: report.totalHours,
        totalMinutes: report.totalMinutes,
        isSigned: isSigned ?? report.isSigned,
        isSent: isSent ?? report.isSent,
      );
      notifyListeners();
    }
  }

  bool hasReportForWeek(int weekNumber, int year) {
    return _reports.any((r) => r.weekNumber == weekNumber && r.year == year);
  }
} 