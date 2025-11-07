import 'package:flutter/material.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/pages/announcement_form_page.dart';

class AnnouncementEmptyState extends StatelessWidget {
  const AnnouncementEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pengumuman',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementFormPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Buat Pengumuman'),
          ),
        ],
      ),
    );
  }
}
