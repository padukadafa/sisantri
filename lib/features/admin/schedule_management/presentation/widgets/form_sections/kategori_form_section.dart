import 'package:flutter/material.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import '../../utils/jadwal_form_helpers.dart';
import '../../utils/schedule_helpers.dart';

/// Widget untuk section pemilihan kategori
class KategoriFormSection extends StatelessWidget {
  final TipeJadwal selectedKategori;
  final List<TipeJadwal> kategoriOptions;
  final Function(TipeJadwal?) onKategoriChanged;

  const KategoriFormSection({
    super.key,
    required this.selectedKategori,
    required this.kategoriOptions,
    required this.onKategoriChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Kegiatan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kategoriOptions.map((kategori) {
            final isSelected = selectedKategori == kategori;
            final color = ScheduleHelpers.getKategoriColor(kategori);

            return ChoiceChip(
              label: Text(JadwalFormHelpers.getKategoriDisplayName(kategori)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onKategoriChanged(kategori);
                }
              },
              selectedColor: color.withOpacity(0.2),
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
