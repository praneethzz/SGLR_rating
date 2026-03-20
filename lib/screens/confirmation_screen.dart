import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../main.dart';
import '../models/inspection.dart';

class ConfirmationScreen extends StatelessWidget {
  final InspectionResult result;

  const ConfirmationScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kAppBar,
        title: const Text('Submitted for Approval'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Success icon
            CircleAvatar(
              radius: 36,
              backgroundColor: kGreenBtn,
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 20),

            const Text(
              'Submitted for Approval',
              style: TextStyle(
                color: kCyan,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              result.resortName,
              style: const TextStyle(color: kOffWhite, fontSize: 16),
            ),
            Text(
              result.area,
              style: const TextStyle(color: kMuted, fontSize: 13),
            ),

            const SizedBox(height: 24),

            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderC),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _Row('Date & Time', _fmt(result.dateTime)),
                  Divider(color: kBorderC, height: 20),
                  _Row(
                    'Total Score',
                    '${result.totalMarks} / ${result.maxMarks}'
                        ' (${result.percentage.toStringAsFixed(1)}%)',
                  ),
                  Divider(color: kBorderC, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SGLR Rating',
                        style: TextStyle(color: kMuted, fontSize: 13),
                      ),
                      RatingBarIndicator(
                        rating: result.starRating.toDouble(),
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: kGold),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                    ],
                  ),
                  Divider(color: kBorderC, height: 20),

                  // Pending badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: kAmberBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF92400E).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: kAmberText,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pending District Committee Approval',
                          style: TextStyle(
                            color: kAmberText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Back to Resort List button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                icon: const Icon(Icons.home, size: 18),
                label: const Text(
                  'Back to Resort List',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text(
                'Start New Inspection',
                style: TextStyle(color: kCyan, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Row extends StatelessWidget {
  final String label, value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: kMuted, fontSize: 13)),
      Text(
        value,
        style: const TextStyle(
          color: kOffWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
