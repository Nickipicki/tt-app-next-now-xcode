import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static const List<ColorOption> colorOptions = [
    ColorOption(
      name: 'Violett',
      color: Colors.purple,
      colorCode: 0xFF9B6B9D,
    ),
    ColorOption(
      name: 'Blau',
      color: Colors.blue,
      colorCode: 0xFF6B7DB3,
    ),
    ColorOption(
      name: 'Grün',
      color: Colors.green,
      colorCode: 0xFF7BA891,
    ),
    ColorOption(
      name: 'Orange',
      color: Colors.orange,
      colorCode: 0xFFD4A373,
    ),
    ColorOption(
      name: 'Rosa',
      color: Colors.pink,
      colorCode: 0xFFCBA6C3,
    ),
  ];

  ColorOption _selectedColor = colorOptions[0];
  
  ColorOption get selectedColor => _selectedColor;
  
  void setColor(ColorOption color) {
    _selectedColor = color;
    notifyListeners();
  }

  ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(_selectedColor.colorCode),
      secondary: Colors.green.shade400,
      background: const Color(0xFF1a1a1a),
    ),
    useMaterial3: true,
  );
}

class ColorOption {
  final String name;
  final MaterialColor color;
  final int colorCode;

  const ColorOption({
    required this.name,
    required this.color,
    required this.colorCode,
  });
} 