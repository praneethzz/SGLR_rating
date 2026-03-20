import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/inspection.dart';

class ConfirmationScreen extends StatelessWidget {
  final InspectionResult result;

  const ConfirmationScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitted for Approval'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF166534),
              child: Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),

            // Heading
            const Text(
              'Submitted for Approval',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C63),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.resortName,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            Text(
              result.area,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),

            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _Row('Date & Time', _fmt(result.dateTime)),
                    const Divider(height: 20),

                    _Row(
                      'Total Score',
                      '${result.totalMarks} / ${result.maxMarks} '
                          '(${result.percentage.toStringAsFixed(1)}%)',
                    ),
                    const Divider(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SGLR Rating',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        RatingBarIndicator(
                          rating: result.starRating.toDouble(),
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: Color(0xFFFFB800)),
                          itemCount: 5,
                          itemSize: 22,
                        ),
                      ],
                    ),

                    if (result.notes.isNotEmpty) ...[
                      const Divider(height: 20),
                      _Row('Officer Notes', result.notes),
                    ],

                    const Divider(height: 20),

                    // Pending status badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD97706)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            color: Color(0xFF92400E),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Pending District Committee Approval',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Back to Resort List button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                icon: const Icon(Icons.home, size: 18),
                label: const Text('Back to Resort List'),
              ),
            ),
            const SizedBox(height: 12),

            // Start new inspection
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Start New Inspection'),
            ),

            const SizedBox(height: 40),
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
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    ],
  );
}
