import 'package:flutter/material.dart';

/// Widget dropdown untuk memilih target audience pengumuman
class AnnouncementTargetDropdown extends StatelessWidget {
  final String value;
  final bool isReadOnly;
  final ValueChanged<String?>? onChanged;

  const AnnouncementTargetDropdown({
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
        labelText: 'Target Audience',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('Semua')),
        DropdownMenuItem(value: 'santri', child: Text('Santri')),
        DropdownMenuItem(value: 'dewan_guru', child: Text('Dewan Guru')),
      ],
      onChanged: isReadOnly ? null : onChanged,
    );
  }
}
