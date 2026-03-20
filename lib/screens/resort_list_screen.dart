import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../main.dart';
import '../data/resorts_data.dart';
import '../models/resort.dart';
import '../services/storage_service.dart';
import 'inspection_form_screen.dart';
import 'role_select_screen.dart';

class ResortListScreen extends StatefulWidget {
  const ResortListScreen({super.key});

  @override
  State<ResortListScreen> createState() => _ResortListScreenState();
}

class _ResortListScreenState extends State<ResortListScreen> {
  Map<int, String> _statuses = {};
  Map<int, int> _stars = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final Map<int, String> statuses = {};
    final Map<int, int> stars = {};

    for (final r in allResorts) {
      statuses[r.id] = await StorageService.getResortStatus(r.id);
      if (statuses[r.id] != 'unrated') {
        final res = await StorageService.loadInspectionResult(r.id);
        if (res != null) stars[r.id] = res.starRating;
      }
    }

    setState(() {
      _statuses = statuses;
      _stars = stars;
      _loading = false;
    });
  }

  Future<void> _handleTap(Resort resort) async {
    if (resort.roomCount == 0) return;

    final status = _statuses[resort.id] ?? 'unrated';

    if (status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pending District Committee approval.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFB45309),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (status == 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rating approved and frozen for this cycle.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: kRedText,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final draft = await StorageService.loadDraft(resort.id);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InspectionFormScreen(resort: resort, draftAnswers: draft),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = resortsByArea;
    final areas = grouped.keys.toList();

    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kAppBar,
        title: const Text('SGLR Rating'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kCyan))
          : Row(
              children: [
                // Left cyan accent stripe
                Container(width: 3, color: kCyan),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // RESORTS heading
                      const Text(
                        'RESORTS',
                        style: TextStyle(
                          color: kCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 16),
                        width: 32,
                        height: 2,
                        color: kCyan,
                      ),

                      // Flat list of all resorts
                      ...areas.expand(
                        (area) => grouped[area]!.map(
                          (resort) => _ResortTile(
                            resort: resort,
                            status: _statuses[resort.id] ?? 'unrated',
                            stars: _stars[resort.id] ?? 0,
                            onTap: () => _handleTap(resort),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ResortTile extends StatelessWidget {
  final Resort resort;
  final String status;
  final int stars;
  final VoidCallback onTap;

  const _ResortTile({
    required this.resort,
    required this.status,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUC = resort.roomCount == 0;
    final isApproved = status == 'approved';
    final isPending = status == 'pending';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderC, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circle avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBgCard,
                shape: BoxShape.circle,
                border: Border.all(color: kCyan, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${resort.id}',
                  style: const TextStyle(
                    color: kCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status
                  Row(
                    children: [
                      Text(
                        resort.name,
                        style: const TextStyle(
                          color: kOffWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isApproved)
                        RatingBarIndicator(
                          rating: stars.toDouble(),
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: kGold),
                          itemCount: 5,
                          itemSize: 14,
                        ),
                      if (!isApproved && !isUC)
                        Text(
                          isPending ? '(Pending)' : '(Unrated)',
                          style: TextStyle(
                            color: isPending ? kAmberText : kMuted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Labels
                  Text(
                    'AREA: ${resort.area}',
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'MANAGER: ${resort.ownerName.isEmpty ? 'N/A' : resort.ownerName}',
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'ROOMS: ${resort.roomCount == 0 ? 'Under Construction' : resort.roomCount.toString()}',
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing icon
            if (isUC)
              const Text('U/C', style: TextStyle(color: kMuted, fontSize: 11))
            else if (isApproved)
              const Icon(Icons.lock, color: kCyan, size: 18)
            else if (isPending)
              const Icon(Icons.access_time, color: kAmberText, size: 18)
            else
              const Icon(Icons.chevron_right, color: kCyan, size: 20),
          ],
        ),
      ),
    );
  }
}
