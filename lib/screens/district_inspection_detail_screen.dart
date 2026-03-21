import 'package:flutter/material.dart';
import '../main.dart';
import '../data/checklist_data.dart';
import '../models/resort.dart';
import '../models/inspection.dart';
import '../services/storage_service.dart';

class DistrictInspectionDetailScreen extends StatefulWidget {
  final Resort resort;
  final InspectionResult result;
  final String status;

  const DistrictInspectionDetailScreen({
    super.key,
    required this.resort,
    required this.result,
    required this.status,
  });

  @override
  State<DistrictInspectionDetailScreen> createState() => _DistrictInspectionDetailScreenState();
}

class _DistrictInspectionDetailScreenState extends State<DistrictInspectionDetailScreen> {
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

  Future<void> _approve() async {
    final ok = await _confirm(
      'Approve ${widget.resort.name}?',
      'Freezes the ${widget.result.starRating}-star rating permanently.',
    );
    if (!ok) return;
    await StorageService.approveInspection(widget.resort.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.resort.name} — approved and frozen.'),
          backgroundColor: kGreenBtn,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _reevaluate() async {
    final ok = await _confirm(
      'Send for reevaluation?',
      '${widget.resort.name} will be fully reset.',
    );
    if (!ok) return;
    await StorageService.sendForReevaluation(widget.resort.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.resort.name} — sent for reevaluation.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _unfreeze() async {
    final ok = await _confirm(
      'Unfreeze ${widget.resort.name}?',
      'This will move the rating back to Pending status.',
    );
    if (!ok) return;
    await StorageService.unfreezeInspection(widget.resort.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.resort.name} — rating unfrozen, moved to pending.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _remove() async {
    final ok = await _confirm(
      'Remove ${widget.resort.name}?',
      'This will permanently delete the inspection result and reset the resort to unrated.',
    );
    if (!ok) return;
    await StorageService.removeInspection(widget.resort.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.resort.name} — inspection removed.'),
          backgroundColor: kRedText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final isApproved = widget.status == 'approved';
    final groups = itemsByCategory;
    
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kAppBar,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Inspection Details', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(r.resortName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kOffWhite)),
            Text(r.area, style: const TextStyle(fontSize: 14, color: kMuted)),
            const SizedBox(height: 24),
            
            // Checklist
            ...groups.entries.map((e) {
              final cat = e.key;
              final items = e.value;
              int catTotal = 0;
              final maxCat = maxMarksForCategory(cat);
              
              final itemWidgets = items.map((item) {
                final hasYes = r.checklistAnswers[item.id] ?? false;
                final earned = hasYes ? item.marks : 0;
                catTotal += earned;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kBgCard, 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorderC, width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.id, style: const TextStyle(color: kMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(item.label, style: const TextStyle(color: kOffWhite, fontSize: 13)),
                          ]
                        )
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasYes ? kGreenBtn.withOpacity(0.1) : kRedText.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(hasYes ? 'YES' : 'NO', style: TextStyle(color: hasYes ? kGreenBtn : kRedText, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 6),
                          Text('$earned / ${item.marks}', style: const TextStyle(color: kMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]
                      )
                    ]
                  )
                );
              }).toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(cat, style: const TextStyle(color: kCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...itemWidgets,
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Text('Category Score: $catTotal / $maxCat', 
                      style: const TextStyle(color: kOffWhite, fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              );
            }),
            
            const Divider(color: kBorderC, height: 32),
            
            Text('Overall Total: ${r.totalMarks} / ${r.maxMarks}', 
              style: const TextStyle(color: kCyan, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            if (!isApproved) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenBtn,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _approve,
                icon: const Icon(Icons.verified, size: 18),
                label: const Text('Approve Rating', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kRedText,
                  side: const BorderSide(color: kRedText, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _reevaluate,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Send for Reevaluation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
            
            if (isApproved) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kCyan,
                  side: const BorderSide(color: kCyan, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _unfreeze,
                icon: const Icon(Icons.lock_open, size: 18),
                label: const Text('Unfreeze Rating', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kRedText,
                  side: const BorderSide(color: kRedText, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _remove,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove Inspection', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
