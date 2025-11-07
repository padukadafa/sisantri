import 'package:flutter/material.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/features/admin/announcement_management/presentation/pages/announcement_form_page.dart';

class AnnouncementFab extends StatelessWidget {
  const AnnouncementFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnnouncementFormPage()),
        );
      },
      label: const Icon(Icons.add),
      backgroundColor: AppTheme.primaryColor,
    );
  }
}
