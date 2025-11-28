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
  final String? selectedMateriJenis; // quran, hadist, atau lainnya
  final Function(String? id, String? nama, String? jenis) onMateriChanged;
  final TextEditingController? temaController;
  final TextEditingController? ayatMulaiController;
  final TextEditingController? ayatSelesaiController;
  final TextEditingController? halamanMulaiController;
  final TextEditingController? halamanSelesaiController;

  const MateriFormSection({
    super.key,
    required this.selectedKategori,
    this.selectedPemateriId,
    this.selectedPemateriNama,
    required this.onPemateriChanged,
    this.selectedMateriId,
    this.selectedMateriNama,
    this.selectedMateriJenis,
    required this.onMateriChanged,
    this.temaController,
    this.ayatMulaiController,
    this.ayatSelesaiController,
    this.halamanMulaiController,
    this.halamanSelesaiController,
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
            onMateriChanged: (id, nama, jenis) {
              onMateriChanged(id, nama, jenis);
            },
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

        // Ayat (untuk materi jenis Al-Quran)
        if (selectedMateriJenis == 'quran' &&
            ayatMulaiController != null &&
            ayatSelesaiController != null) ...[
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

        // Halaman (untuk materi jenis hadist atau lainnya)
        if (selectedMateriJenis != null &&
            selectedMateriJenis != 'quran' &&
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
