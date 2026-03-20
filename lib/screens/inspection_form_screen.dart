import 'package:flutter/material.dart';
import '../models/resort.dart';
import '../data/checklist_data.dart';
import 'rating_screen.dart';

class InspectionFormScreen extends StatefulWidget {
  final Resort resort;

  const InspectionFormScreen({super.key, required this.resort});

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  final Map<String, bool> _answers = {};

  int get _totalMarks => allChecklistItems
      .where((i) => _answers[i.id] == true)
      .fold(0, (s, i) => s + i.marks);

  int get _maxMarks => allChecklistItems.fold(0, (s, i) => s + i.marks);

  @override
  Widget build(BuildContext context) {
    final grouped = itemsByCategory;
    final categories = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resort.name, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _ScoreBanner(scored: _totalMarks, max: _maxMarks),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...categories.map((cat) {
            final items = grouped[cat]!;
            final catMax = maxMarksForCategory(cat);
            final catScored = items
                .where((i) => _answers[i.id] == true)
                .fold(0, (s, i) => s + i.marks);

            return _CategorySection(
              category: cat,
              items: items,
              answers: _answers,
              scored: catScored,
              max: catMax,
              onChanged: (id, val) => setState(() => _answers[id] = val),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        answeredCount: _answers.length,
        totalCount: allChecklistItems.length,
        onProceed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => RatingScreen(
            resort: widget.resort,
            answers: Map.from(_answers),
            totalMarks: _totalMarks,
            maxMarks: _maxMarks,
          ))),
      ),
    );
  }
}

class _ScoreBanner extends StatelessWidget {
  final int scored, max;

  const _ScoreBanner({required this.scored, required this.max});

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? scored / max : 0.0;

    return Container(
      color: const Color(0xFF0F2A50),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Score: $scored / $max',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('${(pct * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 0.85 ? Colors.greenAccent
              : pct >= 0.65 ? Colors.amberAccent : Colors.redAccent),
          ),
        ),
      ]),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ChecklistItem> items;
  final Map<String, bool> answers;
  final int scored, max;
  final void Function(String id, bool val) onChanged;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.answers,
    required this.scored,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A6B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(category, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            Text('$scored / $max marks',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ...items.map((item) => _ChecklistRow(
        item: item,
        value: answers[item.id],
        onChanged: (val) => onChanged(item.id, val),
      )),
    ]);
  }
}

class _ChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  final bool? value;
  final void Function(bool val) onChanged;

  const _ChecklistRow({required this.item, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: value == true ? const Color(0xFFE8F5E9)
           : value == false ? const Color(0xFFFFF3E0) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: const TextStyle(fontSize: 13, height: 1.4)),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B3A6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${item.marks} marks', style: const TextStyle(
                    fontSize: 11, color: Color(0xFF1B3A6B),
                    fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Text(item.subcategory, style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ],
          )),
          const SizedBox(width: 8),
          Row(children: [
            _ToggleBtn(label: 'Yes', active: value == true,
              color: Colors.green, onTap: () => onChanged(true)),
            const SizedBox(width: 4),
            _ToggleBtn(label: 'No', active: value == false,
              color: Colors.orange, onTap: () => onChanged(false)),
          ]),
        ]),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: active ? Colors.white : Colors.grey)),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  final int answeredCount, totalCount;
  final VoidCallback onProceed;

  const _BottomBar({
    required this.answeredCount,
    required this.totalCount,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      boxShadow: const [BoxShadow(
        color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
    ),
    child: Row(children: [
      Text('$answeredCount / $totalCount answered',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      const Spacer(),
      ElevatedButton.icon(
        onPressed: onProceed,
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: const Text('Proceed to Rating')),
    ]),
  );
}