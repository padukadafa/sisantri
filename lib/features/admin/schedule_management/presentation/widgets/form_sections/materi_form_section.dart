import 'package:flutter/material.dart';
import 'package:sisantri/shared/models/jadwal_model.dart';
import 'pemateri_selector.dart';
import 'materi_selector.dart';

/// Widget untuk section form materi kajian
class MateriFormSection extends StatelessWidget {
  final TipeJadwal selectedKategori;
  final String? selectedPemateriId;
  final String? selectedPemateriNama;
  final Function(String? id, String? nama) onPemateriChanged;
  final String? selectedMateriId;
  final String? selectedMateriNama;
  final Function(String? id, String? nama) onMateriChanged;
  final TextEditingController? temaController;
  final TextEditingController? surahController;
  final TextEditingController? ayatMulaiController;
  final TextEditingController? ayatSelesaiController;
  final TextEditingController? halamanMulaiController;
  final TextEditingController? halamanSelesaiController;
  final TextEditingController? hadistMulaiController;
  final TextEditingController? hadistSelesaiController;

  const MateriFormSection({
    super.key,
    required this.selectedKategori,
    this.selectedPemateriId,
    this.selectedPemateriNama,
    required this.onPemateriChanged,
    this.selectedMateriId,
    this.selectedMateriNama,
    required this.onMateriChanged,
    this.temaController,
    this.surahController,
    this.ayatMulaiController,
    this.ayatSelesaiController,
    this.halamanMulaiController,
    this.halamanSelesaiController,
    this.hadistMulaiController,
    this.hadistSelesaiController,
  });

  bool get _isPengajianOrKajian {
    return selectedKategori == TipeJadwal.pengajian;
  }

  bool get _isTahfidz {
    return selectedKategori == TipeJadwal.tahfidz;
  }

  @override
  Widget build(BuildContext context) {
    // Hanya tampilkan section ini untuk kategori pengajian, kajian, atau tahfidz
    if (!_isPengajianOrKajian && !_isTahfidz) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Materi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Materi Kajian (untuk pengajian/kajian) - Dropdown dari Firebase
        if (_isPengajianOrKajian) ...[
          MateriSelector(
            selectedMateriId: selectedMateriId,
            selectedMateriNama: selectedMateriNama,
            onMateriChanged: onMateriChanged,
          ),
          const SizedBox(height: 12),
        ],

        // Pemateri (untuk pengajian/kajian) - Dropdown dari dewan guru
        if (_isPengajianOrKajian) ...[
          PemateriSelector(
            selectedPemateriId: selectedPemateriId,
            selectedPemateriNama: selectedPemateriNama,
            onPemateriChanged: onPemateriChanged,
          ),
          const SizedBox(height: 12),
        ],

        // Surah dan Ayat (untuk kajian Al-Quran / Tahfidz)
        if ((_isPengajianOrKajian || _isTahfidz) &&
            surahController != null) ...[
          TextFormField(
            controller: surahController,
            decoration: const InputDecoration(
              labelText: 'Nama Surah',
              hintText: 'Contoh: Al-Baqarah',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.book),
            ),
          ),
          const SizedBox(height: 12),

          // Ayat Mulai dan Selesai
          if (ayatMulaiController != null && ayatSelesaiController != null) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ayatMulaiController,
                    decoration: const InputDecoration(
                      labelText: 'Ayat Mulai',
                      hintText: '1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 1) {
                          return 'Harus angka > 0';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: ayatSelesaiController,
                    decoration: const InputDecoration(
                      labelText: 'Ayat Selesai',
                      hintText: '10',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 1) {
                          return 'Harus angka > 0';
                        }
                        // Validasi ayat selesai >= ayat mulai
                        final mulai = int.tryParse(
                          ayatMulaiController?.text ?? '',
                        );
                        if (mulai != null && num < mulai) {
                          return 'Harus >= ayat mulai';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],

        // Halaman (untuk kajian kitab umum)
        if (_isPengajianOrKajian &&
            halamanMulaiController != null &&
            halamanSelesaiController != null) ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: halamanMulaiController,
                  decoration: const InputDecoration(
                    labelText: 'Halaman Mulai',
                    hintText: '1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Harus angka > 0';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: halamanSelesaiController,
                  decoration: const InputDecoration(
                    labelText: 'Halaman Selesai',
                    hintText: '10',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Harus angka > 0';
                      }
                      // Validasi halaman selesai >= halaman mulai
                      final mulai = int.tryParse(
                        halamanMulaiController?.text ?? '',
                      );
                      if (mulai != null && num < mulai) {
                        return 'Harus >= hal mulai';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
