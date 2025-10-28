#!/bin/bash

echo "🔧 Fixing Pengumuman Model Imports..."
echo "======================================"
echo ""

cd /home/android/Documents/flutter/sisantri

# Fix all wrong pengumuman model imports to use the correct one in shared/models
echo "📝 Replacing incorrect pengumuman model imports..."

find lib/features -type f -name "*.dart" -exec sed -i \
  "s|import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';|import 'package:sisantri/shared/models/pengumuman_model.dart';|g" {} +

find lib/features -type f -name "*.dart" -exec sed -i \
  "s|import 'package:sisantri/features/pengumuman/data/models/pengumuman_model.dart';|import 'package:sisantri/shared/models/pengumuman_model.dart';|g" {} +

find lib/features -type f -name "*.dart" -exec sed -i \
  "s|import 'package:sisantri/features/admin/presentation/models/pengumuman_model.dart';|import 'package:sisantri/shared/models/pengumuman_model.dart';|g" {} +

echo ""
echo "✅ Pengumuman imports fixed!"
echo "======================================"
