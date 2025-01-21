import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/time_entries_provider.dart';
import 'providers/report_provider.dart';

// Import der Seiten
import 'pages/time_tracking_page.dart';
import 'pages/calendar_page.dart';
import 'pages/reports_page.dart';
import 'pages/profile_page.dart';

// Import der Widgets
import 'widgets/time_entries_calendar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('de_DE').then((_) => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TimeEntriesProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTZ App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3498db),
          secondary: Color(0xFFf39c12),
          surface: Color(0xFF1c2331),
          background: Color(0xFF0d121e),
        ),
        cardTheme: CardTheme(
          color: Colors.white.withOpacity(0.03),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498db),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TimeTrackingPage(),
    const CalendarPage(),
    const ReportsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: const BoxDecoration(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1c2331),
                Color(0xFF0d121e),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 65,
            selectedIndex: _selectedIndex,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
            destinations: [
              _buildNavItem(0, Icons.timer_outlined, Icons.timer, 'Timer'),
              _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, 'Kalender'),
              _buildNavItem(2, Icons.description_outlined, Icons.description, 'Rapporte'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
            ],
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavItem(
    int index, 
    IconData outlinedIcon, 
    IconData filledIcon, 
    String label
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    
    return NavigationDestination(
      icon: Icon(
        outlinedIcon,
        color: isSelected 
            ? theme.colorScheme.primary 
            : Colors.white.withOpacity(0.5),
      ),
      selectedIcon: Icon(
        filledIcon,
        color: theme.colorScheme.primary,
      ),
      label: label,
    );
  }
} 