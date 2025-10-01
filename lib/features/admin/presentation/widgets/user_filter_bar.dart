import 'package:flutter/material.dart';

/// Widget untuk filter dan search bar users
class UserFilterBar extends StatelessWidget {
  final String selectedFilter;
  final String searchQuery;
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;

  const UserFilterBar({
    super.key,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('santri', 'Santri'),
                  const SizedBox(width: 8),
                  _buildFilterChip('guru', 'Guru'),
                  const SizedBox(width: 8),
                  _buildFilterChip('admin', 'Admin'),
                  const SizedBox(width: 8),
                  _buildFilterChip('active', 'Aktif'),
                  const SizedBox(width: 8),
                  _buildFilterChip('inactive', 'Tidak Aktif'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }
}
