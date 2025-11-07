import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/features/shared/pengumuman/data/models/announcement_model.dart';
import 'package:sisantri/features/shared/pengumuman/presentation/pages/announcement_detail_page.dart';

class PengumumanListItem extends StatelessWidget {
  final AnnouncementModel item;

  const PengumumanListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailPage(announcement: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.isHighPriority
                    ? Colors.red.withAlpha(15)
                    : AppTheme.primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.isHighPriority
                      ? Colors.red.withAlpha(50)
                      : AppTheme.primaryColor.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Icon(
                item.isHighPriority ? Icons.priority_high : Icons.campaign,
                color: item.isHighPriority ? Colors.red : AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2E2E2E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isHighPriority)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.red.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Penting',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.konten,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(item.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
