import 'package:flutter/material.dart';
import 'dart:async';
import '../models/time_entry.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../widgets/time_entry_dialog.dart';
import '../widgets/time_entries_calendar.dart'; // Für kEvents

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage> with SingleTickerProviderStateMixin {
  String status = 'stopped'; // 'stopped', 'working', 'paused'
  DateTime? startTime;
  DateTime? pauseStartTime;
  int totalWorkSeconds = 0;
  int totalPauseSeconds = 0;
  Timer? timer;

  // Animation Controller als nullable deklarieren
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  final double dailyGoalHours = 8.0; // 8 Stunden Tagesziel

  String? selectedLocation; // Kann null sein
  List<String> savedLocations = []; // Liste der gespeicherten Orte/Kostenstellen

  @override
  void initState() {
    super.initState();
    print('TimeTrackingPage initialized');
    print('kEvents contains ${kEvents.length} entries');
    // Liste ein paar Beispiel-Einträge auf
    kEvents.forEach((date, entries) {
      print('Date: $date has ${entries.length} entries');
    });
    
    // Timer setup
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (status != 'stopped') {
        setState(() {
          if (status == 'working') {
            totalWorkSeconds = DateTime.now().difference(startTime!).inSeconds - totalPauseSeconds;
          } else if (status == 'paused' && pauseStartTime != null) {
            totalPauseSeconds = totalPauseSeconds + 
                DateTime.now().difference(pauseStartTime!).inSeconds;
          }
        });
      }
    });

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  void startTimer() {
    startTime = DateTime.now();
    totalWorkSeconds = 0;
    totalPauseSeconds = 0;
    setState(() {
      status = 'working';
    });
  }

  void pauseTimer() {
    pauseStartTime = DateTime.now();
    setState(() {
      status = 'paused';
    });
  }

  void resumeTimer() {
    if (pauseStartTime != null) {
      totalPauseSeconds = totalPauseSeconds + 
          DateTime.now().difference(pauseStartTime!).inSeconds;
      pauseStartTime = null;
    }
    setState(() {
      status = 'working';
    });
  }

  void stopTimer() {
    if (startTime != null && selectedLocation != null) {
      // Berechne finale Zeiten
      if (status == 'paused' && pauseStartTime != null) {
        totalPauseSeconds = totalPauseSeconds + 
            DateTime.now().difference(pauseStartTime!).inSeconds;
      }
      
      // Verwende einen anderen Variablennamen für die lokale Berechnung
      final workSeconds = DateTime.now().difference(startTime!).inSeconds - totalPauseSeconds;

      // Erstelle neuen Zeiteintrag
      final entry = TimeEntry(
        location: selectedLocation!,
        startTime: startTime!,
        endTime: DateTime.now(),
        pauseMinutes: (totalPauseSeconds / 60).round(),
      );

      // Füge Eintrag zum heutigen Tag hinzu
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      
      final entries = kEvents[today] ?? [];
      kEvents[today] = [...entries, entry];

      // Zeige Bestätigung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zeiteintrag gespeichert: ${entry.location} (${(workSeconds / 3600).toStringAsFixed(2)} Stunden)',
          ),
          action: SnackBarAction(
            label: 'Anzeigen',
            onPressed: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
        ),
      );

      // Reset Timer
      setState(() {
        status = 'stopped';
        startTime = null;
        pauseStartTime = null;
        totalWorkSeconds = 0;
        totalPauseSeconds = 0;
      });
    } else if (selectedLocation == null) {
      // Zeige Warnung wenn keine Location ausgewählt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wählen Sie zuerst eine Kostenstelle aus'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String getWorkTimeString() {
    if (status == 'stopped') return '00:00:00';
    return formatTime(totalWorkSeconds);
  }

  String getPauseTimeString() {
    if (status == 'stopped') return '00:00:00';
    return formatTime(totalPauseSeconds);
  }

  void handlePlayPause() {
    if (status == 'stopped') {
      startTimer();
    } else if (status == 'working') {
      pauseTimer();
    } else {
      resumeTimer();
    }
  }

  void handleStop() {
    stopTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = totalWorkSeconds / (dailyGoalHours * 3600);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0d121e),
            Color(0xFF1c2331),
            Color(0xFF2a3441),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Ort/Kostenstelle Selector
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3498db).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _showLocationPicker();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedLocation ?? 'Ort/Kostenstelle auswählen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontStyle: selectedLocation == null ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Progress Circle
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CustomPaint(
                        painter: ProgressCirclePainter(
                          workProgress: progress,
                          pauseProgress: totalPauseSeconds / (dailyGoalHours * 3600),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'von ${dailyGoalHours}h',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Time Cards
              Row(
                children: [
                  Expanded(
                    child: _buildTimeCard(
                      title: 'Arbeitszeit',
                      subtitle: getWorkTimeString(),
                      isActive: status == 'working',
                      activeColor: Color(0xFF3498db),
                      labelColor: Color(0xFF90caf9),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeCard(
                      title: 'Pausenzeit',
                      subtitle: getPauseTimeString(),
                      isActive: status == 'paused',
                      activeColor: Color(0xFFf39c12),
                      labelColor: Color(0xFFffcc80),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    onPressed: handlePlayPause,
                    icon: status == 'working' ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    gradientColors: status == 'working'
                        ? [Color(0xFFe74c3c), Color(0xFFc0392b)]
                        : [Color(0xFF2ecc71), Color(0xFF27ae60)],
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    onPressed: status == 'stopped' ? null : handleStop,
                    icon: Icons.stop_rounded,
                    gradientColors: [Color(0xFFf39c12), Color(0xFFd35400)],
                    disabled: status == 'stopped',
                    size: 48,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  status == 'stopped'
                      ? 'Bereit zum Starten'
                      : status == 'working'
                          ? 'Zeit wird erfasst'
                          : 'Pause läuft',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String subtitle,
    required bool isActive,
    required Color activeColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: labelColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? 'Aktiv' : 'Pause',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    VoidCallback? onPressed,
    required IconData icon,
    required List<Color> gradientColors,
    bool disabled = false,
    double size = 52,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: disabled ? [] : [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFF1c2331),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Ort/Kostenstelle wählen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _showAddLocationDialog();
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            // Gespeicherte Orte
            if (savedLocations.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Noch keine Orte/Kostenstellen gespeichert',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: savedLocations.length,
                itemBuilder: (context, index) {
                  final location = savedLocations[index];
                  return ListTile(
                    title: Text(
                      location,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      Icons.check,
                      color: location == selectedLocation ? Colors.green : Colors.transparent,
                    ),
                    onTap: () {
                      setState(() {
                        selectedLocation = location;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1c2331),
        title: const Text(
          'Neue Kostenstelle',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Name der Kostenstelle',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  savedLocations.add(textController.text);
                  selectedLocation = textController.text;
                });
                Navigator.pop(context); // Dialog schließen
                Navigator.pop(context); // BottomSheet schließen
              }
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}

// Timer Circle Painter
class TimerCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  TimerCirclePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color,
          color.withOpacity(0.8),
        ],
        stops: const [0.0, 1.0],
        startAngle: -1.5708,
        endAngle: 4.7124,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -1.5708, // Start from top (90° = pi/2)
      progress * 6.2832, // 2*pi = 360°
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class DonutChartPainter extends CustomPainter {
  final double progress;
  final double pauseProgress;
  final Color backgroundColor;
  final Color progressColor;
  final Color secondaryColor;
  final double strokeWidth;

  DonutChartPainter({
    required this.progress,
    required this.pauseProgress,
    required this.backgroundColor,
    required this.progressColor,
    required this.secondaryColor,
    this.strokeWidth = 8, // Dünnerer Standardwert
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const startAngle = -math.pi / 2;
    final workSweepAngle = 2 * math.pi * math.min(1, progress);
    final pauseSweepAngle = 2 * math.pi * math.min(1, pauseProgress);

    // Hintergrund
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Arbeitszeit-Fortschritt
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          progressColor.withOpacity(0.7),
          progressColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      workSweepAngle,
      false,
      progressPaint,
    );

    // Pausenzeit-Fortschritt
    if (pauseProgress > 0) {
      final pausePaint = Paint()
        ..shader = SweepGradient(
          colors: [
            secondaryColor.withOpacity(0.7),
            secondaryColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + workSweepAngle,
        pauseSweepAngle,
        false,
        pausePaint,
      );
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pauseProgress != pauseProgress;
  }
}

class ProgressCirclePainter extends CustomPainter {
  final double workProgress;
  final double pauseProgress;
  final Color backgroundColor;

  ProgressCirclePainter({
    required this.workProgress,
    required this.pauseProgress,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const startAngle = -math.pi / 2;
    final workSweepAngle = 2 * math.pi * math.min(1, workProgress);
    final pauseSweepAngle = 2 * math.pi * math.min(1, pauseProgress);

    // Hintergrund
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, bgPaint);

    // Arbeitszeit-Fortschritt
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withOpacity(0.7),
          Colors.white,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      startAngle,
      workSweepAngle,
      false,
      progressPaint,
    );

    // Pausenzeit-Fortschritt
    if (pauseProgress > 0) {
      final pausePaint = Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        startAngle + workSweepAngle,
        pauseSweepAngle,
        false,
        pausePaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressCirclePainter oldDelegate) {
    return oldDelegate.workProgress != workProgress ||
        oldDelegate.pauseProgress != pauseProgress;
  }
}