import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../data/resorts_data.dart';
import '../models/inspection.dart';
import '../models/resort.dart';
import '../services/storage_service.dart';

class DistrictCommitteeScreen extends StatefulWidget {
  const DistrictCommitteeScreen({super.key});

  @override
  State<DistrictCommitteeScreen> createState() =>
      _DistrictCommitteeScreenState();
}

class _DistrictCommitteeScreenState extends State<DistrictCommitteeScreen> {
  List<_PendingItem> _pendingItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final pendingIds = await StorageService.getPendingResortIds();
    final List<_PendingItem> items = [];

    for (final id in pendingIds) {
      final result = await StorageService.loadInspectionResult(id);
      final resort = allResorts.firstWhere(
        (r) => r.id == id,
        orElse: () => Resort(
          id: id,
          name: 'Unknown',
          ownerName: '',
          phone: '',
          area: '',
          roomCount: 0,
        ),
      );
      if (result != null) {
        items.add(_PendingItem(resort: resort, result: result));
      }
    }

    if (mounted) {
      setState(() {
        _pendingItems = items;
        _loading = false;
      });
    }
  }

  void _showApproveSheet(BuildContext context, _PendingItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Approve the ${item.result.starRating}-star rating for '
              '${item.resort.name}?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This cannot be undone.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await StorageService.approveInspection(item.resort.id);
                      setState(() => _pendingItems.remove(item));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.resort.name} — rating approved and frozen.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReevaluateSheet(BuildContext context, _PendingItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send ${item.resort.name} back for reevaluation?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'The inspection will be reset and the Divisional '
              'Committee will need to redo it.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await StorageService.sendForReevaluation(item.resort.id);
                      setState(() => _pendingItems.remove(item));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.resort.name} — sent back for reevaluation.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('District Committee Review'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            color: const Color(0xFF094449),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _loading
                  ? 'Loading...'
                  : '${_pendingItems.length} inspection${_pendingItems.length == 1 ? '' : 's'} pending approval',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendingItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingItems.length,
              itemBuilder: (context, index) {
                return _PendingCard(
                  item: _pendingItems[index],
                  onApprove: () =>
                      _showApproveSheet(context, _pendingItems[index]),
                  onReevaluate: () =>
                      _showReevaluateSheet(context, _pendingItems[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: const Color(0xFF0D5C63).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No pending inspections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D5C63),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All submitted ratings have been reviewed.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PendingItem {
  final Resort resort;
  final InspectionResult result;

  _PendingItem({required this.resort, required this.result});
}

class _PendingCard extends StatelessWidget {
  final _PendingItem item;
  final VoidCallback onApprove;
  final VoidCallback onReevaluate;

  const _PendingCard({
    required this.item,
    required this.onApprove,
    required this.onReevaluate,
  });

  Color get _scoreColor {
    final pct = item.result.totalMarks / item.result.maxMarks * 100;
    if (pct >= 85) return const Color(0xFF166534);
    if (pct >= 65) return const Color(0xFFB45309);
    return const Color(0xFF991B1B);
  }

  String get _grade => [
    'Poor',
    'Below Average',
    'Average',
    'Good',
    'Excellent',
  ][item.result.starRating - 1];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<dynamic>>{};
    for (final entry in item.result.checklistAnswers.entries) {
      // Group by first letter of key (A, B, C)
      final cat = entry.key[0];
      grouped.putIfAbsent(cat, () => []).add(entry);
    }

    final pct = item.result.totalMarks / item.result.maxMarks * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.resort.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.resort.area,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.resort.roomCount} rooms',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Score row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.result.totalMarks}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _scoreColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'out of ${item.result.maxMarks}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _grade,
                      style: TextStyle(color: _scoreColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Star rating
            Center(
              child: RatingBarIndicator(
                rating: item.result.starRating.toDouble(),
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Color(0xFFFFB800)),
                itemCount: 5,
                itemSize: 32,
              ),
            ),
            Center(
              child: Text(
                '${item.result.starRating} / 5 stars (auto-calculated)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Category breakdown
            _BreakdownSection(result: item.result),

            // Officer notes
            if (item.result.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Officer notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.result.notes,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Submission time
            Text(
              'Submitted: ${_fmt(item.result.dateTime)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),

            const SizedBox(height: 16),

            // Approve button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.verified, size: 18),
                label: const Text(
                  'Approve Rating',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Reevaluate button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReevaluate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Send for Reevaluation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
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

class _BreakdownSection extends StatelessWidget {
  final InspectionResult result;

  const _BreakdownSection({required this.result});

  @override
  Widget build(BuildContext context) {
    // Category max marks
    const categoryMaxes = {'A': 80, 'B': 80, 'C': 40};
    const categoryNames = {
      'A': 'A. Faecal Sludge Management',
      'B': 'B. Solid Waste Management',
      'C': 'C. Grey Water Management',
    };

    // Calculate scored per category
    final categoryScores = <String, int>{'A': 0, 'B': 0, 'C': 0};
    for (final entry in result.checklistAnswers.entries) {
      if (entry.value == true) {
        final cat = entry.key[0];
        // We can't recalculate exact marks here without checklist data
        // so we use a proportion approach — but since we have the total
        // we show the breakdown from the saved answers
      }
    }

    // Use totalMarks with category proportions for display
    return Column(
      children: ['A', 'B', 'C'].map((cat) {
        final maxMarks = categoryMaxes[cat]!;
        final name = categoryNames[cat]!;
        // Estimate scored by checking answered items in this category
        final answered = result.checklistAnswers.entries
            .where((e) => e.key.startsWith(cat) && e.value == true)
            .length;
        final total = result.checklistAnswers.entries
            .where((e) => e.key.startsWith(cat))
            .length;

        // Show answered count as proxy
        final displayScore = total > 0
            ? '${answered} / ${total} items'
            : '— / $maxMarks';
        final pct = total > 0 ? answered / total : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(name, style: const TextStyle(fontSize: 12)),
                  ),
                  Text(
                    displayScore,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct.toDouble(),
                  minHeight: 6,
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
      }).toList(),
    );
  }
}
