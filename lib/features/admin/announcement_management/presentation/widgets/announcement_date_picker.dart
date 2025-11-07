import 'package:flutter/material.dart';

/// Widget untuk memilih tanggal dengan date picker
class AnnouncementDatePicker extends StatelessWidget {
  final String title;
  final DateTime? selectedDate;
  final IconData icon;
  final bool isReadOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final VoidCallback? onTap;
  final String emptyText;

  const AnnouncementDatePicker({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.icon,
    this.isReadOnly = false,
    this.firstDate,
    this.lastDate,
    this.onTap,
    this.emptyText = 'Tidak ada batas waktu',
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        selectedDate != null
            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
            : emptyText,
      ),
      leading: Icon(icon),
      trailing: isReadOnly ? null : const Icon(Icons.edit),
      onTap: isReadOnly ? null : onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}
