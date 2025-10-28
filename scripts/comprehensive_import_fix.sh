#!/bin/bash

echo "🔧 Comprehensive Import Fix Script"
echo "===================================="
echo ""

cd /home/android/Documents/flutter/sisantri

# Phase 1: Fix all models to use shared/models
echo "Phase 1: Fixing model imports..."
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|from '../../../shared/models/|from 'package:sisantri/shared/models/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|from '../../shared/models/|from 'package:sisantri/shared/models/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|from '../shared/models/|from 'package:sisantri/shared/models/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../shared/models/|'package:sisantri/shared/models/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../shared/models/|'package:sisantri/shared/models/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../shared/models/|'package:sisantri/shared/models/|g" {} +

# Phase 2: Fix remaining core imports
echo "Phase 2: Fixing remaining core imports..."
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../core/|'package:sisantri/core/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../../core/|'package:sisantri/core/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../../../core/|'package:sisantri/core/|g" {} +

# Phase 3: Fix remaining shared imports  
echo "Phase 3: Fixing remaining shared imports..."
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../shared/|'package:sisantri/shared/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../../shared/|'package:sisantri/shared/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../../../shared/|'package:sisantri/shared/|g" {} +

# Phase 4: Fix all features imports that are still relative
echo "Phase 4: Fixing features imports..."
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../features/|'package:sisantri/features/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../features/|'package:sisantri/features/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../features/|'package:sisantri/features/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../features/|'package:sisantri/features/|g" {} +
find lib/features -type f -name "*.dart" -exec sed -i \
  "s|'../../../../../features/|'package:sisantri/features/|g" {} +

echo ""
echo "✅ All import paths fixed!"
echo "===================================="
