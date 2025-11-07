import 'package:flutter/material.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/announcement_model.dart';

/// Widget untuk menampilkan chips prioritas, kategori, dan status
class AnnouncementCardChips extends StatelessWidget {
  final AnnouncementModel pengumuman;

  const AnnouncementCardChips({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityChip(),
        const SizedBox(width: 8),
        _buildCategoryChip(),
        const Spacer(),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    switch (pengumuman.prioritas) {
      case 'tinggi':
        color = Colors.red;
        break;
      case 'sedang':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        pengumuman.prioritas.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        pengumuman.kategori,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isActive = pengumuman.isActive && !pengumuman.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'AKTIF' : 'TIDAK AKTIF',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
