import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../main.dart';
import '../data/resorts_data.dart';
import '../models/resort.dart';
import '../models/inspection.dart';
import '../services/storage_service.dart';
import 'role_select_screen.dart';
import 'district_inspection_detail_screen.dart';

class DistrictCommitteeScreen extends StatefulWidget {
  const DistrictCommitteeScreen({super.key});

  @override
  State<DistrictCommitteeScreen> createState() =>
      _DistrictCommitteeScreenState();
}

class _PendingItem {
  final Resort resort;
  final InspectionResult result;
  final String status;
  _PendingItem(this.resort, this.result, this.status);
}

class _DistrictCommitteeScreenState extends State<DistrictCommitteeScreen> {
  List<_PendingItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = <_PendingItem>[];

    // Load pending resorts
    final ids = await StorageService.getPendingResortIds();
    for (final id in ids) {
      final result = await StorageService.loadInspectionResult(id);
      final resort = allResorts.firstWhere((r) => r.id == id);
      if (result != null) {
        items.add(_PendingItem(resort, result, 'pending'));
      }
    }

    // Load approved resorts
    for (final r in allResorts) {
      final status = await StorageService.getResortStatus(r.id);
      if (status == 'approved') {
        final result = await StorageService.loadInspectionResult(r.id);
        if (result != null) {
          items.add(_PendingItem(r, result, 'approved'));
        }
      }
    }

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<bool> _confirm(String title, String msg) async =>
      await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: kBgCard2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kOffWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                msg,
                style: const TextStyle(color: kMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kMuted,
                        side: const BorderSide(color: kBorderC),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kCyan,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ) ??
      false;

  Future<void> _approve(_PendingItem item) async {
    final ok = await _confirm(
      'Approve ${item.resort.name}?',
      'Freezes the ${item.result.starRating}-star rating permanently.',
    );
    if (!ok) return;
    await StorageService.approveInspection(item.resort.id);
    setState(() => _items.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.resort.name} — approved and frozen.'),
          backgroundColor: kGreenBtn,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _load();
  }

  Future<void> _reevaluate(_PendingItem item) async {
    final ok = await _confirm(
      'Send for reevaluation?',
      '${item.resort.name} will be fully reset.',
    );
    if (!ok) return;
    await StorageService.sendForReevaluation(item.resort.id);
    setState(() => _items.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.resort.name} — sent for reevaluation.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _unfreeze(_PendingItem item) async {
    final ok = await _confirm(
      'Unfreeze ${item.resort.name}?',
      'This will move the rating back to Pending status.',
    );
    if (!ok) return;
    await StorageService.unfreezeInspection(item.resort.id);
    setState(() => _items.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.resort.name} — rating unfrozen, moved to pending.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _load();
  }

  Future<void> _remove(_PendingItem item) async {
    final ok = await _confirm(
      'Remove ${item.resort.name}?',
      'This will permanently delete the inspection result and reset the resort to unrated.',
    );
    if (!ok) return;
    await StorageService.removeInspection(item.resort.id);
    setState(() => _items.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.resort.name} — inspection removed.'),
          backgroundColor: kRedText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBgPage,
    appBar: AppBar(
      backgroundColor: kAppBar,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
        ),
      ),
      title: const Text('District Committee Review'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: Container(
          color: kAppBarSub,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            '${_items.where((i) => i.status == 'pending').length} pending · '
            '${_items.where((i) => i.status == 'approved').length} approved',
            style: const TextStyle(color: kCyan, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: kCyan))
        : _items.isEmpty
        ? _empty()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) => _Card(
              item: _items[i],
              onTap: () async {
                final changed = await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => DistrictInspectionDetailScreen(
                    resort: _items[i].resort,
                    result: _items[i].result,
                    status: _items[i].status,
                  )
                ));
                if (changed == true) {
                  _load();
                }
              },
            ),
          ),
  );

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: kCyan, size: 64),
        const SizedBox(height: 16),
        const Text(
          'No inspections yet',
          style: TextStyle(
            color: kOffWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'All submitted ratings have been reviewed.',
          style: TextStyle(color: kMuted, fontSize: 14),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final _PendingItem item;
  final VoidCallback onTap;

  const _Card({
    required this.item,
    required this.onTap,
  });

  Color get _sc {
    final p = item.result.percentage;
    return p >= 85
        ? kGreenBtn
        : p >= 65
        ? kAmberText
        : kRedText;
  }

  String get _grade => [
    'Poor',
    'Below Average',
    'Average',
    'Good',
    'Excellent',
  ][item.result.starRating - 1];

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

  @override
  Widget build(BuildContext context) {
    final r = item.result;
    final isApproved = item.status == 'approved';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproved ? kGreenBtn : kBorderC,
          width: isApproved ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isApproved ? kGreenBtn.withOpacity(0.1) : kAmberBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isApproved ? kGreenBtn : kAmberText,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.lock : Icons.hourglass_empty,
                      size: 12,
                      color: isApproved ? kGreenBtn : kAmberText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isApproved ? 'Approved & Frozen' : 'Pending Approval',
                      style: TextStyle(
                        color: isApproved ? kGreenBtn : kAmberText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.resort.roomCount} rooms',
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Resort name and area
          Text(
            r.resortName,
            style: const TextStyle(
              color: kOffWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(r.area, style: const TextStyle(color: kMuted, fontSize: 12)),

          const SizedBox(height: 16),

          // Score
          Text(
            '${r.totalMarks}',
            style: TextStyle(
              color: _sc,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            'out of ${r.maxMarks}',
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
          Text(
            '${r.percentage.toStringAsFixed(1)}% $_grade',
            style: TextStyle(
              color: _sc,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // Stars
          RatingBarIndicator(
            rating: r.starRating.toDouble(),
            itemBuilder: (_, __) => const Icon(Icons.star, color: kGold),
            itemCount: 5,
            itemSize: 22,
          ),
          Text(
            '${r.starRating} / 5 stars (auto-calculated)',
            style: const TextStyle(color: kMuted, fontSize: 11),
          ),

          const SizedBox(height: 14),
          const Divider(color: kBorderC),
          
          Align(
            alignment: Alignment.center,
            child: Text(
              'Tap for full evaluation details',
              style: TextStyle(color: kCyan, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
