import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../data/resorts_data.dart';
import '../models/resort.dart';
import 'inspection_form_screen.dart';

class ResortListScreen extends StatefulWidget {
  const ResortListScreen({super.key});

  @override
  State<ResortListScreen> createState() => _ResortListScreenState();
}

class _ResortListScreenState extends State<ResortListScreen> {
  // Stores star ratings for each resort by id
  final Map<int, int> _ratings = {};

  void updateRating(int resortId, int stars) {
    setState(() => _ratings[resortId] = stars);
  }

  @override
  Widget build(BuildContext context) {
    final resorts = allResorts;

    return Scaffold(
      appBar: AppBar(title: const Text('SGLR Rating')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // RESORTS heading
          const Text(
            'RESORTS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          ...resorts.map(
            (resort) => _ResortTile(
              resort: resort,
              stars: _ratings[resort.id],
              onRatingUpdated: updateRating,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResortTile extends StatelessWidget {
  final Resort resort;
  final int? stars;
  final void Function(int resortId, int stars) onRatingUpdated;

  const _ResortTile({
    required this.resort,
    required this.stars,
    required this.onRatingUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUC = resort.roomCount == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: isUC
              ? Colors.grey.shade300
              : const Color(0xFF1B3A6B),
          child: Text(
            '${resort.id}',
            style: TextStyle(
              color: isUC ? Colors.grey : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              resort.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isUC ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            // Show stars if rated, else show "Unrated"
            stars != null
                ? RatingBarIndicator(
                    rating: stars!.toDouble(),
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: Color(0xFFFFB800)),
                    itemCount: 5,
                    itemSize: 18,
                  )
                : const Text(
                    '(Unrated)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AREA: ${resort.area}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              Text(
                'MANAGER: ${resort.ownerName.isEmpty ? 'N/A' : resort.ownerName}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              Text(
                'Rooms: ${resort.roomCount == 0 ? 'Under Construction' : resort.roomCount.toString()}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
        trailing: isUC
            ? const Chip(label: Text('U/C', style: TextStyle(fontSize: 11)))
            : const Icon(Icons.chevron_right, color: Color(0xFF1B3A6B)),
        onTap: isUC
            ? null
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InspectionFormScreen(
                      resort: resort,
                      onInspectionComplete: (stars) =>
                          onRatingUpdated(resort.id, stars),
                    ),
                  ),
                );
              },
      ),
    );
  }
}
