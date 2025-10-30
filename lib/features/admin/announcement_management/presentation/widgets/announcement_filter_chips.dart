import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';

/// Widget untuk filter chips pengumuman
class AnnouncementFilterChips extends ConsumerWidget {
  const AnnouncementFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Semua',
              icon: Icons.list,
              isSelected: true,
              onTap: () {
                // TODO: Implement filter
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Dipublikasi',
              icon: Icons.publish,
              isSelected: false,
              onTap: () {
                // TODO: Implement filter
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Draft',
              icon: Icons.drafts,
              isSelected: false,
              onTap: () {
                // TODO: Implement filter
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Prioritas Tinggi',
              icon: Icons.priority_high,
              isSelected: false,
              onTap: () {
                // TODO: Implement filter
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Disematkan',
              icon: Icons.push_pin,
              isSelected: false,
              onTap: () {
                // TODO: Implement filter
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
