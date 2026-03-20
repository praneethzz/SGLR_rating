import 'package:flutter/material.dart';
import 'resort_list_screen.dart';
import 'district_committee_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App icon / logo area
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5C63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.beach_access,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'SGLR Beach Resort\nInspection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5C63),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Collector Office — Andhra Pradesh',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.waves,
                      color: const Color(0xFF0D5C63).withOpacity(0.4),
                      size: 20,
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                ],
              ),

              const Spacer(flex: 2),

              // Select role label
              const Text(
                'Select your role to continue',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Divisional Committee button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ResortListScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Divisional Committee',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Inspect & rate resorts',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // District Committee button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DistrictCommitteeScreen(),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D5C63),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0D5C63), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'District Committee',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Review & approve ratings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0D5C63),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
