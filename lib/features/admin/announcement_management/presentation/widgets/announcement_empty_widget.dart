import 'package:flutter/material.dart';

/// Widget untuk menampilkan empty state saat tidak ada pengumuman
class AnnouncementEmptyWidget extends StatelessWidget {
  const AnnouncementEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada pengumuman',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
