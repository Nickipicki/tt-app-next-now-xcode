class Report {
  final int weekNumber;
  final int year;
  final DateTime generatedAt;
  final String pdfPath;
  final int totalHours;
  final int totalMinutes;
  final bool isSigned;
  final bool isSent;

  Report({
    required this.weekNumber,
    required this.year,
    required this.generatedAt,
    required this.pdfPath,
    required this.totalHours,
    required this.totalMinutes,
    required this.isSigned,
    required this.isSent,
  });

  // Kopier-Konstruktor für Updates
  Report copyWith({
    int? weekNumber,
    int? year,
    DateTime? generatedAt,
    String? pdfPath,
    int? totalHours,
    int? totalMinutes,
    bool? isSigned,
    bool? isSent,
  }) {
    return Report(
      weekNumber: weekNumber ?? this.weekNumber,
      year: year ?? this.year,
      generatedAt: generatedAt ?? this.generatedAt,
      pdfPath: pdfPath ?? this.pdfPath,
      totalHours: totalHours ?? this.totalHours,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      isSigned: isSigned ?? this.isSigned,
      isSent: isSent ?? this.isSent,
    );
  }
} 