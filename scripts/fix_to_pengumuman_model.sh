#!/bin/bash

echo "🔧 Fixing Pengumuman to use Model instead of Entity..."
echo "======================================================="
echo ""

cd /home/android/Documents/flutter/sisantri

# Update announcement_management to use AnnouncementModel
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|import 'package:sisantri/features/shared/pengumuman/domain/entities/pengumuman.dart';|import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';|g" {} +

# Also add alias for easier use
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|<List<Pengumuman>>|<List<AnnouncementModel>>|g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|<Pengumuman>|<AnnouncementModel>|g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s| Pengumuman | AnnouncementModel |g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|(Pengumuman |(AnnouncementModel |g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|, Pengumuman>|, AnnouncementModel>|g" {} +

echo ""
echo "✅ announcement_management now uses AnnouncementModel!"
echo "======================================================"
