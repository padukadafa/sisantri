import 'package:flutter/material.dart';

import 'package:sisantri/core/theme/app_theme.dart';

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Statistik Kehadiran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
      ],
    );
  }
}
