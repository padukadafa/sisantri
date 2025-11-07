import 'package:flutter/material.dart';
import 'package:sisantri/shared/widgets/reusable_text_field.dart';

/// Widget untuk input field judul dan konten pengumuman
class AnnouncementFormFields extends StatelessWidget {
  final TextEditingController judulController;
  final TextEditingController kontenController;
  final bool isReadOnly;

  const AnnouncementFormFields({
    super.key,
    required this.judulController,
    required this.kontenController,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Judul
        ReusableTextField(
          controller: judulController,
          labelText: 'Judul Pengumuman *',
          prefixIcon: Icons.title,
          readOnly: isReadOnly,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Judul harus diisi';
            }
            return null;
          },
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),

        // Konten
        ReusableTextField(
          controller: kontenController,
          labelText: 'Konten Pengumuman *',
          prefixIcon: Icons.description,
          readOnly: isReadOnly,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konten harus diisi';
            }
            return null;
          },
          maxLines: 8,
          minLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
