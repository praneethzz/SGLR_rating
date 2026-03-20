import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/resort.dart';
import '../models/inspection.dart';
import '../data/checklist_data.dart';
import '../services/storage_service.dart';
import 'confirmation_screen.dart';

class RatingScreen extends StatefulWidget {
  final Resort resort;
  final Map<String, bool> answers;
  final int totalMarks, maxMarks;

  const RatingScreen({
    super.key,
    required this.resort,
    required this.answers,
    required this.totalMarks,
    required this.maxMarks,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _notesController = TextEditingController();
  bool _submitting = false;

  int get _stars => InspectionResult.calculateStars(widget.totalMarks);
  double get _pct => (widget.totalMarks / widget.maxMarks) * 100;

  Color get _scoreColor => _pct >= 85
      ? const Color(0xFF166534)
      : _pct >= 65
      ? const Color(0xFFB45309)
      : const Color(0xFF991B1B);

  String get _grade =>
      ['Poor', 'Below Average', 'Average', 'Good', 'Excellent'][_stars - 1];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitInspection() async {
    setState(() => _submitting = true);

    final result = InspectionResult(
      resortName: widget.resort.name,
      area: widget.resort.area,
      resortId: widget.resort.id,
      dateTime: DateTime.now(),
      checklistAnswers: widget.answers,
      totalMarks: widget.totalMarks,
      maxMarks: widget.maxMarks,
      starRating: _stars,
      notes: _notesController.text.trim(),
    );

    // Save result, set status to pending, clear draft
    await StorageService.saveInspectionResult(widget.resort.id, result);
    await StorageService.setResortStatus(widget.resort.id, 'pending');
    await StorageService.clearDraft(widget.resort.id);

    if (!mounted) return;

    // Navigate to confirmation, clear form and rating from stack
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
                        color: Color(0xFF0D5C63),
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
                      itemBuilder: (_, __) =>
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

            // Score breakdown
            const Text(
              'Score Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C63),
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

            // Officer notes
            const Text(
              'Officer Notes (optional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C63),
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

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submitInspection,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 20),
                label: Text(
                  _submitting
                      ? 'Submitting...'
                      : 'Submit to District Committee',
                  style: const TextStyle(fontSize: 16),
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
