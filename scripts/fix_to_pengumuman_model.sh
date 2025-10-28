#!/bin/bash

echo "🔧 Fixing Pengumuman to use Model instead of Entity..."
echo "======================================================="
echo ""

cd /home/android/Documents/flutter/sisantri

# Update announcement_management to use PengumumanModel
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|import 'package:sisantri/features/shared/pengumuman/domain/entities/pengumuman.dart';|import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';|g" {} +

# Also add alias for easier use
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|<List<Pengumuman>>|<List<PengumumanModel>>|g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|<Pengumuman>|<PengumumanModel>|g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s| Pengumuman | PengumumanModel |g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|(Pengumuman |(PengumumanModel |g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|, Pengumuman>|, PengumumanModel>|g" {} +

echo ""
echo "✅ announcement_management now uses PengumumanModel!"
echo "======================================================"
