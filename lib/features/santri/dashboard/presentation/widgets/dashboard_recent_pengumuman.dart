import 'package:flutter/material.dart';

import '../../../../shared/models/pengumuman_model.dart';
import 'pengumuman_header.dart';
import 'pengumuman_empty_state.dart';
import 'pengumuman_list_item.dart';

class DashboardRecentPengumuman extends StatelessWidget {
  final List<PengumumanModel> pengumuman;

  const DashboardRecentPengumuman({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PengumumanHeader(),
        const SizedBox(height: 16),
        if (pengumuman.isEmpty)
          const PengumumanEmptyState()
        else
          ...pengumuman.take(3).map((item) => PengumumanListItem(item: item)),
      ],
    );
  }
}
