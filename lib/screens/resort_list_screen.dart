import 'package:flutter/material.dart';
import '../data/resorts_data.dart';
import '../models/resort.dart';
import 'inspection_form_screen.dart';

class ResortListScreen extends StatelessWidget {
  const ResortListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grouped = resortsByArea;
    final areas = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Resort Inspections'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            color: const Color(0xFF0F2A50),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${allResorts.length} resorts across ${areas.length} areas',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: areas.length,
        itemBuilder: (context, areaIndex) {
          final area = areas[areaIndex];
          final resorts = grouped[area]!;
          return _AreaSection(area: area, resorts: resorts);
        },
      ),
    );
  }
}

class _AreaSection extends StatelessWidget {
  final String area;
  final List<Resort> resorts;

  const _AreaSection({required this.area, required this.resorts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(children: [
            Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0F6E56),
                borderRadius: BorderRadius.circular(2)
              )
            ),
            const SizedBox(width: 8),
            Text(area, style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B3A6B)
            )),
            const SizedBox(width: 8),
            Text('(${resorts.length})',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ),
        ...resorts.map((resort) => _ResortTile(resort: resort)),
      ],
    );
  }
}

class _ResortTile extends StatelessWidget {
  final Resort resort;

  const _ResortTile({required this.resort});

  @override
  Widget build(BuildContext context) {
    final bool isUC = resort.roomCount == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isUC ? Colors.grey.shade200 : const Color(0xFF1B3A6B),
          child: Text('${resort.id}', style: TextStyle(
            color: isUC ? Colors.grey : Colors.white,
            fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text(resort.name, style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isUC ? Colors.grey : null)),
        subtitle: Text(
          isUC ? 'Under construction'
            : '${resort.ownerName} • ${resort.roomCount} rooms',
          style: TextStyle(fontSize: 12,
            color: isUC ? Colors.grey : Colors.grey.shade600)),
        trailing: isUC
          ? const Chip(label: Text('U/C', style: TextStyle(fontSize: 11)))
          : const Icon(Icons.chevron_right, color: Color(0xFF1B3A6B)),
        onTap: isUC ? null : () => Navigator.push(context,
          MaterialPageRoute(builder: (_) =>
            InspectionFormScreen(resort: resort))),
      ),
    );
  }
}