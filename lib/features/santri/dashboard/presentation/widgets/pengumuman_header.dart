import 'package:flutter/material.dart';

import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/features/shared/pengumuman/presentation/announcement_page.dart';

class PengumumanHeader extends StatelessWidget {
  const PengumumanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Pengumuman Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => AnnouncementPage()));
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: const Text(
            'Lihat Semua',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
