import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBlue = Color(0xFF0A0F2D);
  static const Color primaryBlue = Color(0xFF1C2840);
  static const Color accentBlue = Color(0xFF4F74B9);
  static const Color purple = Color(0xFF9747FF);
  static const Color lightBlue = Color(0xFFCDDBF0);

  static const Gradient logoGradient = LinearGradient(
    colors: [accentBlue, purple, lightBlue],
    stops: [0.22, 0.6, 1.0],
  );

  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentBlue, purple],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: darkBlue,
      fontFamily: 'Roboto',
    );
  }
}