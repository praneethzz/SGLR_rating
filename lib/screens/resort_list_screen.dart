import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../data/resorts_data.dart';
import '../models/resort.dart';
import '../services/storage_service.dart';
import 'inspection_form_screen.dart';

class ResortListScreen extends StatefulWidget {
  const ResortListScreen({super.key});

  @override
  State<ResortListScreen> createState() => _ResortListScreenState();
}

class _ResortListScreenState extends State<ResortListScreen> {
  Map<int, String> _resortStatuses = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    final Map<int, String> statuses = {};
    for (final resort in allResorts) {
      statuses[resort.id] = await StorageService.getResortStatus(resort.id);
    }
    if (mounted) {
      setState(() {
        _resortStatuses = statuses;
        _loading = false;
      });
    }
  }

  Future<void> _openInspection(Resort resort) async {
    final draft = await StorageService.loadDraft(resort.id);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InspectionFormScreen(resort: resort, draftAnswers: draft),
      ),
    );
    _loadStatuses();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('SGLR Rating'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0D5C63),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // RESORTS heading
                const Text(
                  'RESORTS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 12),

                // Flat resort list
                ...allResorts.map((resort) {
                  final status = _resortStatuses[resort.id] ?? 'unrated';
                  return _ResortTile(
                    resort: resort,
                    status: status,
                    onTap: () {
                      if (resort.roomCount == 0) return;
                      if (status == 'pending') {
                        _showSnackBar(
                          'This inspection is pending District Committee approval. No changes can be made.',
                        );
                      } else if (status == 'approved') {
                        _showSnackBar(
                          'This resort has an approved rating. Inspection is closed for this cycle.',
                        );
                      } else {
                        _openInspection(resort);
                      }
                    },
                  );
                }),
              ],
            ),
    );
  }
}

class _ResortTile extends StatelessWidget {
  final Resort resort;
  final String status;
  final VoidCallback onTap;

  const _ResortTile({
    required this.resort,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUC = resort.roomCount == 0;

    // Avatar colour based on status
    Color avatarColor;
    if (isUC) {
      avatarColor = Colors.grey.shade300;
    } else if (status == 'pending') {
      avatarColor = const Color(0xFFD97706);
    } else if (status == 'approved') {
      avatarColor = const Color(0xFF166534);
    } else {
      avatarColor = const Color(0xFF0D5C63);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        // Number avatar
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            '${resort.id}',
            style: TextStyle(
              color: isUC ? Colors.grey : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Title: name + stars or unrated
        title: Row(
          children: [
            Text(
              resort.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isUC ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            if (isUC)
              const SizedBox()
            else if (status == 'approved')
              RatingBarIndicator(
                rating: 0,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Color(0xFFFFB800)),
                itemCount: 5,
                itemSize: 16,
              )
            else if (status == 'pending')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const Text(
                '(Unrated)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),

        // Subtitle: area, manager, rooms
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: isUC
              ? const Text(
                  'Under construction',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AREA: ${resort.area}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'MANAGER: ${resort.ownerName.isEmpty ? 'N/A' : resort.ownerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Rooms: ${resort.roomCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),

        // Trailing icon
        trailing: isUC
            ? const Chip(label: Text('U/C', style: TextStyle(fontSize: 11)))
            : status == 'pending'
            ? const Icon(Icons.hourglass_empty, color: Color(0xFFD97706))
            : status == 'approved'
            ? const Icon(Icons.lock, color: Color(0xFF166534))
            : const Icon(Icons.chevron_right, color: Color(0xFF0D5C63)),

        onTap: isUC ? null : onTap,
      ),
    );
  }
}
