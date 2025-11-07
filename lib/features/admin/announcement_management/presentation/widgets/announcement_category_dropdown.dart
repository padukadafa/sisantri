import 'package:flutter/material.dart';

/// Widget dropdown untuk memilih kategori pengumuman
class AnnouncementCategoryDropdown extends StatelessWidget {
  final String value;
  final bool isReadOnly;
  final ValueChanged<String?>? onChanged;

  const AnnouncementCategoryDropdown({
    super.key,
    required this.value,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(value: 'umum', child: Text('Umum')),
        DropdownMenuItem(value: 'penting', child: Text('Penting')),
        DropdownMenuItem(value: 'mendesak', child: Text('Mendesak')),
        DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
        DropdownMenuItem(value: 'kegiatan', child: Text('Kegiatan')),
      ],
      onChanged: isReadOnly ? null : onChanged,
    );
  }
}
