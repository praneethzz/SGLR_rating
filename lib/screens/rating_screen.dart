import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/resort.dart';
import '../models/inspection.dart';
import '../data/checklist_data.dart';
import 'confirmation_screen.dart';

class RatingScreen extends StatefulWidget {
  final Resort resort;
  final Map<String, bool> answers;
  final int totalMarks, maxMarks;
  final void Function(int stars) onInspectionComplete;

  const RatingScreen({
    super.key,
    required this.resort,
    required this.answers,
    required this.totalMarks,
    required this.maxMarks,
    required this.onInspectionComplete,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _notesController = TextEditingController();

  int get _stars => InspectionResult.calculateStars(widget.totalMarks);

  double get _pct => (widget.totalMarks / widget.maxMarks) * 100;

  Color get _scoreColor => _pct >= 85
      ? Colors.green.shade700
      : _pct >= 65
      ? Colors.amber.shade700
      : Colors.red.shade700;

  String get _grade =>
      ['Poor', 'Below Average', 'Average', 'Good', 'Excellent'][_stars - 1];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final result = InspectionResult(
      resortName: widget.resort.name,
      area: widget.resort.area,
      dateTime: DateTime.now(),
      checklistAnswers: widget.answers,
      totalMarks: widget.totalMarks,
      maxMarks: widget.maxMarks,
      starRating: _stars,
      notes: _notesController.text.trim(),
    );

    widget.onInspectionComplete(_stars);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ConfirmationScreen(result: result)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = itemsByCategory;

    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      widget.resort.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3A6B),
                      ),
                    ),
                    Text(
                      widget.resort.area,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${widget.totalMarks}',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      'out of ${widget.maxMarks}',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_pct.toStringAsFixed(1)}% — $_grade',
                      style: TextStyle(
                        fontSize: 16,
                        color: _scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RatingBarIndicator(
                      rating: _stars.toDouble(),
                      itemBuilder: (_, _) =>
                          const Icon(Icons.star, color: Color(0xFFFFB800)),
                      itemCount: 5,
                      itemSize: 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_stars / 5 stars (auto-calculated)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Breakdown
            const Text(
              'Score Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B3A6B),
              ),
            ),
            const SizedBox(height: 8),

            ...grouped.entries.map((e) {
              final catMax = e.value.fold(0, (s, i) => s + i.marks);
              final catScored = e.value
                  .where((i) => widget.answers[i.id] == true)
                  .fold(0, (s, i) => s + i.marks);
              return _BreakdownRow(
                category: e.key,
                scored: catScored,
                max: catMax,
              );
            }),

            const SizedBox(height: 20),

            // Notes
            const Text(
              'Officer Notes (optional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B3A6B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Add any observations, violations, or follow-up notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text(
                  'Submit Inspection',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String category;
  final int scored, max;

  const _BreakdownRow({
    required this.category,
    required this.scored,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? scored / max : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(category, style: const TextStyle(fontSize: 13)),
              ),
              Text(
                '$scored / $max',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 0.8
                    ? Colors.green
                    : pct >= 0.5
                    ? Colors.amber
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
