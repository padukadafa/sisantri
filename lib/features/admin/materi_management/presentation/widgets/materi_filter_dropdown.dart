import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/shared/models/materi_model.dart';
import 'package:sisantri/shared/providers/materi_provider.dart';

/// Widget dropdown untuk filter materi kajian
class MateriFilterDropdown extends ConsumerWidget {
  const MateriFilterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(materiFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JenisMateri?>(
          value: currentFilter,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: Colors.white,
          onChanged: (JenisMateri? newValue) {
            ref.read(materiFilterProvider.notifier).state = newValue;
          },
          items: [
            _buildDropdownItem(null, 'Semua Jenis'),
            _buildDropdownItem(JenisMateri.quran, 'Al-Quran'),
            _buildDropdownItem(JenisMateri.hadist, 'Hadist'),
            _buildDropdownItem(JenisMateri.lainnya, 'Lainnya'),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<JenisMateri?> _buildDropdownItem(
    JenisMateri? value,
    String label,
  ) {
    return DropdownMenuItem<JenisMateri?>(
      value: value,
      child: Text(
        label,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}
