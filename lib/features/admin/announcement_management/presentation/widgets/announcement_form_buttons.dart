import 'package:flutter/material.dart';
import 'package:sisantri/core/theme/app_theme.dart';

/// Widget untuk tombol aksi form (Batal dan Publikasi)
class AnnouncementFormButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onPublish;

  const AnnouncementFormButtons({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onPublish,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Publikasi',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
