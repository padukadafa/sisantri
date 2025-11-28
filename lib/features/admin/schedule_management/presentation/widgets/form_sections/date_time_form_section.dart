import 'package:flutter/material.dart';
import 'package:sisantri/features/admin/schedule_management/presentation/utils/schedule_helpers.dart';

/// Widget untuk section tanggal dan waktu
class DateTimeFormSection extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final Function(DateTime?) onDateChanged;
  final Function(TimeOfDay) onWaktuMulaiChanged;
  final Function(TimeOfDay) onWaktuSelesaiChanged;

  const DateTimeFormSection({
    super.key,
    required this.selectedDate,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.onDateChanged,
    required this.onWaktuMulaiChanged,
    required this.onWaktuSelesaiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tanggal
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Tanggal'),
          subtitle: Text(
            selectedDate != null
                ? ScheduleHelpers.formatDate(selectedDate!)
                : 'Pilih tanggal',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectDate(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 16),
        // Waktu Mulai & Selesai
        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Mulai'),
                subtitle: Text(ScheduleHelpers.formatTime(waktuMulai)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectTime(context, true),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Selesai'),
                subtitle: Text(ScheduleHelpers.formatTime(waktuSelesai)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _selectTime(context, false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? waktuMulai : waktuSelesai,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartTime) {
        onWaktuMulaiChanged(picked);
      } else {
        onWaktuSelesaiChanged(picked);
      }
    }
  }
}
