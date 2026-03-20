import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../main.dart';
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
  final _notes = TextEditingController();

  int get _stars => InspectionResult.calculateStars(widget.totalMarks);
  double get _pct => (widget.totalMarks / widget.maxMarks) * 100;
  String get _grade =>
      ['Poor', 'Below Average', 'Average', 'Good', 'Excellent'][_stars - 1];
  Color get _scoreColor => _pct >= 85
      ? kGreenBtn
      : _pct >= 65
      ? kAmberText
      : kRedText;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = InspectionResult(
      resortId: widget.resort.id,
      resortName: widget.resort.name,
      area: widget.resort.area,
      dateTime: DateTime.now(),
      checklistAnswers: widget.answers,
      totalMarks: widget.totalMarks,
      maxMarks: widget.maxMarks,
      starRating: _stars,
      notes: _notes.text.trim(),
    );

    await StorageService.saveInspectionResult(widget.resort.id, result);
    await StorageService.setResortStatus(widget.resort.id, 'pending');
    await StorageService.clearDraft(widget.resort.id);

    if (!mounted) return;

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
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kAppBar,
        title: const Text('Inspection Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderC),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.resort.name,
                    style: const TextStyle(
                      color: kCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.resort.area,
                    style: const TextStyle(color: kMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.totalMarks}',
                    style: TextStyle(
                      color: _scoreColor,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'out of 200',
                    style: TextStyle(color: kMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_pct.toStringAsFixed(1)}% — $_grade',
                    style: TextStyle(
                      color: _scoreColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RatingBarIndicator(
                    rating: _stars.toDouble(),
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: kGold),
                    itemCount: 5,
                    itemSize: 32,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_stars / 5 stars (auto-calculated)',
                    style: const TextStyle(color: kMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Score breakdown
            const Text(
              'Score Breakdown',
              style: TextStyle(
                color: kCyan,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            ...grouped.entries.map((e) {
              final catMax = e.value.fold(0, (s, i) => s + i.marks);
              final catScored = e.value
                  .where((i) => widget.answers[i.id] == true)
                  .fold(0, (s, i) => s + i.marks);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(color: kOffWhite, fontSize: 13),
                    ),
                    Text(
                      '$catScored / $catMax',
                      style: const TextStyle(
                        color: kOffWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Officer notes
            const Text(
              'Officer Notes (optional)',
              style: TextStyle(
                color: kCyan,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 4,
              style: const TextStyle(color: kOffWhite, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Add observations, violations, or notes...',
                hintStyle: TextStyle(color: kMuted),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
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
                onPressed: _submit,
                icon: const Icon(Icons.send, size: 18),
                label: const Text(
                  'Submit to District Committee',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
