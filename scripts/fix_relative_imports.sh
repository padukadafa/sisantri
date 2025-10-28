#!/bin/bash

echo "🔧 Fixing Relative Imports to Absolute..."
echo "=========================================="
echo ""

cd /home/android/Documents/flutter/sisantri

echo "📝 Converting relative imports in admin/announcement_management..."
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|import '../../../core/theme/app_theme.dart';|import 'package:sisantri/core/theme/app_theme.dart';|g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|import '../../../shared/helpers/messaging_helper.dart';|import 'package:sisantri/shared/helpers/messaging_helper.dart';|g" {} +
find lib/features/admin/announcement_management -type f -name "*.dart" -exec sed -i \
  "s|import '../models/pengumuman_model.dart';|import 'package:sisantri/features/shared/pengumuman/data/models/pengumuman_model.dart';|g" {} +

echo "📝 Converting relative imports in admin folders..."
find lib/features/admin -type f -name "*.dart" -exec sed -i \
  "s|import '../../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/admin -type f -name "*.dart" -exec sed -i \
  "s|import '../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/admin -type f -name "*.dart" -exec sed -i \
  "s|import '../core/|import 'package:sisantri/core/|g" {} +

find lib/features/admin -type f -name "*.dart" -exec sed -i \
  "s|import '../../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/admin -type f -name "*.dart" -exec sed -i \
  "s|import '../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/admin -type f -name "*.dart" -exec sed -i \
  "s|import '../shared/|import 'package:sisantri/shared/|g" {} +

echo "📝 Converting relative imports in santri folders..."
find lib/features/santri -type f -name "*.dart" -exec sed -i \
  "s|import '../../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/santri -type f -name "*.dart" -exec sed -i \
  "s|import '../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/santri -type f -name "*.dart" -exec sed -i \
  "s|import '../core/|import 'package:sisantri/core/|g" {} +

find lib/features/santri -type f -name "*.dart" -exec sed -i \
  "s|import '../../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/santri -type f -name "*.dart" -exec sed -i \
  "s|import '../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/santri -type f -name "*.dart" -exec sed -i \
  "s|import '../shared/|import 'package:sisantri/shared/|g" {} +

echo "📝 Converting relative imports in dewan_guru folders..."
find lib/features/dewan_guru -type f -name "*.dart" -exec sed -i \
  "s|import '../../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/dewan_guru -type f -name "*.dart" -exec sed -i \
  "s|import '../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/dewan_guru -type f -name "*.dart" -exec sed -i \
  "s|import '../core/|import 'package:sisantri/core/|g" {} +

find lib/features/dewan_guru -type f -name "*.dart" -exec sed -i \
  "s|import '../../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/dewan_guru -type f -name "*.dart" -exec sed -i \
  "s|import '../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/dewan_guru -type f -name "*.dart" -exec sed -i \
  "s|import '../shared/|import 'package:sisantri/shared/|g" {} +

echo "📝 Converting relative imports in shared folders..."
find lib/features/shared -type f -name "*.dart" -exec sed -i \
  "s|import '../../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/shared -type f -name "*.dart" -exec sed -i \
  "s|import '../../core/|import 'package:sisantri/core/|g" {} +
find lib/features/shared -type f -name "*.dart" -exec sed -i \
  "s|import '../core/|import 'package:sisantri/core/|g" {} +

find lib/features/shared -type f -name "*.dart" -exec sed -i \
  "s|import '../../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/shared -type f -name "*.dart" -exec sed -i \
  "s|import '../../shared/|import 'package:sisantri/shared/|g" {} +
find lib/features/shared -type f -name "*.dart" -exec sed -i \
  "s|import '../shared/|import 'package:sisantri/shared/|g" {} +

echo ""
echo "✅ Relative imports conversion completed!"
echo "========================================="
