import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';

void main() {
  runApp(const BeachInspectionApp());
}

class BeachInspectionApp extends StatelessWidget {
  const BeachInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGLR Beach Resort Inspection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C63),
          secondary: const Color(0xFFD97706),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D5C63),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D5C63),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
      ),
      home: const RoleSelectScreen(),
    );
  }
}
