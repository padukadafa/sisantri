import 'package:flutter/material.dart';

class KegiatanEmptyState extends StatelessWidget {
  const KegiatanEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy, size: 32, color: Colors.grey[400]),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada kegiatan mendatang',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
