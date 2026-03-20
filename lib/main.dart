import 'package:flutter/material.dart';
import 'screens/resort_list_screen.dart';

void main() {
  runApp(const BeachInspectionApp());
}

class BeachInspectionApp extends StatelessWidget {
  const BeachInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beach Inspection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3A6B),
          secondary: const Color(0xFF0F6E56),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B3A6B),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B3A6B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const ResortListScreen(),
    );
  }
}