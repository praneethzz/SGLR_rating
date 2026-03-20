import 'package:flutter/material.dart';
import '../main.dart';
import '../models/resort.dart';
import '../data/checklist_data.dart';
import '../services/storage_service.dart';
import 'rating_screen.dart';

class InspectionFormScreen extends StatefulWidget {
  final Resort resort;
  final Map<String, bool>? draftAnswers;

  const InspectionFormScreen({
    super.key,
    required this.resort,
    this.draftAnswers,
  });

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  late Map<String, bool> _answers;

  @override
  void initState() {
    super.initState();
    _answers = Map.from(widget.draftAnswers ?? {});
    if (widget.draftAnswers != null && widget.draftAnswers!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft restored — continuing where you left off.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  int get _totalMarks => allChecklistItems
      .where((i) => _answers[i.id] == true)
      .fold(0, (s, i) => s + i.marks);

  int get _maxMarks => allChecklistItems.fold(0, (s, i) => s + i.marks);

  Future<void> _toggle(String id, bool val) async {
    setState(() => _answers[id] = val);
    await StorageService.saveDraft(widget.resort.id, _answers);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = itemsByCategory;
    final pct = _maxMarks > 0 ? _totalMarks / _maxMarks : 0.0;

    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kAppBar,
        title: Text(widget.resort.name, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: kAppBarSub,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $_totalMarks / $_maxMarks',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(kCyan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...grouped.keys.map((cat) {
            final items = grouped[cat]!;
            final catMax = maxMarksForCategory(cat);
            final catScored = items
                .where((i) => _answers[i.id] == true)
                .fold(0, (s, i) => s + i.marks);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat,
                      style: const TextStyle(
                        color: kCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$catScored / $catMax marks',
                      style: const TextStyle(color: kMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...items.map(
                  (item) => _ChecklistCard(
                    item: item,
                    value: _answers[item.id],
                    onToggle: (val) => _toggle(item.id, val),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kBgCard2,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Row(
          children: [
            Text(
              '${_answers.length} / ${allChecklistItems.length} answered',
              style: const TextStyle(color: kMuted, fontSize: 13),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RatingScreen(
                    resort: widget.resort,
                    answers: Map.from(_answers),
                    totalMarks: _totalMarks,
                    maxMarks: _maxMarks,
                  ),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Proceed to Rating'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final ChecklistItem item;
  final bool? value;
  final void Function(bool) onToggle;

  const _ChecklistCard({
    required this.item,
    this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kBgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kBorderC, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  color: kOffWhite,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kCyanLite,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.marks} marks',
                      style: const TextStyle(
                        color: kCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.subcategory,
                    style: const TextStyle(color: kMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            _Btn('Yes', value == true, kGreenBtn, () => onToggle(true)),
            const SizedBox(height: 6),
            _Btn('No', value == false, kRedText, () => onToggle(false)),
          ],
        ),
      ],
    ),
  );
}

class _Btn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _Btn(this.label, this.active, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 52,
      height: 32,
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : kBgCard2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? color : kBorderC, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : kMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
