import 'package:flutter/material.dart';
import '../main.dart';
import 'resort_list_screen.dart';
import 'district_committee_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kBgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kCyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: kCyan.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.beach_access, color: kCyan, size: 40),
              ),

              const SizedBox(height: 28),

              // Title
              const Text(
                'SGLR Beach Resort',
                style: TextStyle(
                  color: kOffWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Inspection',
                style: TextStyle(
                  color: kCyan,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Wave divider
              const Text(
                '~ ~ ~',
                style: TextStyle(color: kCyan, fontSize: 16, letterSpacing: 6),
              ),

              const Spacer(flex: 2),

              // Role label
              const Text(
                'SELECT YOUR ROLE TO CONTINUE',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Divisional Committee button
              _RoleButton(
                title: 'Divisional Committee',
                subtitle: 'Inspect & rate resorts',
                filled: true,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ResortListScreen()),
                ),
              ),

              const SizedBox(height: 14),

              // District Committee button
              _RoleButton(
                title: 'District Committee',
                subtitle: 'Review & approve ratings',
                filled: false,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DistrictCommitteeScreen(),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title, subtitle;
  final bool filled;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: filled ? kBgCard2 : kBgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCyan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: filled ? kOffWhite : kCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: kMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
