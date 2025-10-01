import 'package:flutter/material.dart';

/// Widget untuk search dan filter pengumuman
class AnnouncementSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedFilter;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;

  const AnnouncementSearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengumuman...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('semua', 'Semua'),
                _buildFilterChip('aktif', 'Aktif'),
                _buildFilterChip('expired', 'Kadaluarsa'),
                _buildFilterChip('draft', 'Draft'),
                _buildFilterChip('penting', 'Penting'),
                _buildFilterChip('urgent', 'Urgent'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onFilterChanged(value);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }
}
