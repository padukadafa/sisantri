import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class KegiatanHeader extends StatelessWidget {
  const KegiatanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.event_available,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'Kegiatan Mendatang',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
      ],
    );
  }
}
