import 'package:flutter/material.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import '../../utils/jadwal_form_helpers.dart';

/// Widget untuk section form dasar (nama, deskripsi, tempat)
class BasicInfoFormSection extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController deskripsiController;
  final TextEditingController tempatController;
  final TipeJadwal selectedKategori;

  const BasicInfoFormSection({
    super.key,
    required this.namaController,
    required this.deskripsiController,
    required this.tempatController,
    required this.selectedKategori,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: namaController,
          decoration: InputDecoration(
            labelText: 'Nama Kegiatan',
            hintText: JadwalFormHelpers.getHintTextForKategori(
              selectedKategori,
            ),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.event),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama kegiatan harus diisi';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: deskripsiController,
          decoration: const InputDecoration(
            labelText: 'Deskripsi',
            hintText: 'Tambahkan deskripsi singkat kegiatan',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: tempatController,
          decoration: InputDecoration(
            labelText: 'Tempat',
            hintText: JadwalFormHelpers.getTempatHintForKategori(
              selectedKategori,
            ),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Tempat harus diisi';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
