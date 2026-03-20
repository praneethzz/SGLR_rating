import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';

// ── Colour constants ─────────────────────────────────────
const kBgPage = Color(0xFFF8FAFC);
const kBgCard = Color(0xFFFFFFFF);
const kBgCard2 = Color(0xFFF1F5F9);
const kAppBar = Color(0xFF0D5C6B);
const kAppBarSub = Color(0xFF0A4A58);
const kCyan = Color(0xFF00BCD4);
const kCyanDark = Color(0xFF00838F);
const kCyanLite = Color(0xFFE0F7FA);
const kGold = Color(0xFFF59E0B);
const kGreenBtn = Color(0xFF16A34A);
const kRedText = Color(0xFFDC2626);
const kAmberText = Color(0xFF92400E);
const kAmberBg = Color(0xFFFEF3C7);
const kOffWhite = Color(0xFF1E293B);
const kMuted = Color(0xFF64748B);
const kBorderC = Color(0xFFCBD5E1);

void main() => runApp(const BeachInspectionApp());

class BeachInspectionApp extends StatelessWidget {
  const BeachInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGLR Beach Inspection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBgPage,
        colorScheme: const ColorScheme.light(
          primary: kCyan,
          secondary: kGold,
          surface: kBgCard,
          onPrimary: Colors.white,
          onSurface: kOffWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kAppBar,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kCyan,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kOffWhite, fontSize: 15),
          bodyMedium: TextStyle(color: kOffWhite, fontSize: 13),
          bodySmall: TextStyle(color: kMuted, fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kBgCard2,
          hintStyle: const TextStyle(color: kMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorderC),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorderC),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kCyan, width: 1.5),
          ),
        ),
      ),
      home: const RoleSelectScreen(),
    );
  }
}
