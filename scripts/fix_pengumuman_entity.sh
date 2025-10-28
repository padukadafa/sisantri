#!/bin/bash

echo "🔧 Fixing Pengumuman Import to Entity..."
echo "========================================="
echo ""

cd /home/android/Documents/flutter/sisantri

# Fix semua import Pengumuman model yang salah ke entity
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|import 'package:sisantri/shared/models/pengumuman_model.dart';|import 'package:sisantri/features/shared/pengumuman/domain/entities/pengumuman.dart';|g" {} +

echo ""
echo "✅ Pengumuman imports fixed to use entity!"
echo "========================================="
