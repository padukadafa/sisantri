#!/bin/bash

echo "🚀 Starting Role-Based Import Path Migration..."
echo "================================================"
echo ""

cd /home/android/Documents/flutter/sisantri

# Backup current state
echo "📦 Creating backup..."
git add . 2>/dev/null || echo "⚠️  Git not initialized, skipping backup"
echo ""

echo "🔄 Phase 1: Updating Admin Feature Imports..."
echo "----------------------------------------------"

# Admin features - user management
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/user_management_page|features/admin/user_management/presentation/pages/user_management_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/providers/user_management_providers|features/admin/user_management/presentation/providers/user_management_providers|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/services/user_management_service|features/admin/user_management/presentation/services/user_management_service|g' {} +

# Admin features - attendance
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/manual_attendance_page|features/admin/attendance_management/presentation/pages/manual_attendance_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/attendance_report_page|features/admin/attendance_management/presentation/pages/attendance_report_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/attendance_report/providers/attendance_report_providers|features/admin/attendance_management/presentation/providers/attendance_report_providers|g' {} +

# Admin features - announcement
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/announcement_management_page|features/admin/announcement_management/presentation/pages/announcement_management_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/providers/announcement_providers|features/admin/announcement_management/presentation/providers/announcement_providers|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/services/announcement_service|features/admin/announcement_management/presentation/services/announcement_service|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/widgets/announcement_|features/admin/announcement_management/presentation/widgets/announcement_|g' {} +

# Admin features - schedule
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/schedule_management_page|features/admin/schedule_management/presentation/pages/schedule_management_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/add_edit_jadwal_page|features/admin/schedule_management/presentation/pages/add_edit_jadwal_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/schedule/|features/admin/schedule_management/presentation/|g' {} +

# Admin features - dashboard, materi, notification
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/admin_dashboard_page|features/admin/dashboard/presentation/pages/admin_dashboard_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/materi_management_page|features/admin/materi_management/presentation/pages/materi_management_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/admin/presentation/notification_management_page|features/admin/notification_management/presentation/pages/notification_management_page|g' {} +

echo "✅ Admin imports updated"
echo ""

echo "🔄 Phase 2: Updating Santri Feature Imports..."
echo "----------------------------------------------"

# Santri features - dashboard
find lib -type f -name "*.dart" -exec sed -i \
  's|features/dashboard/presentation/pages/dashboard_page|features/santri/dashboard/presentation/pages/santri_dashboard_page|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/dashboard/presentation/providers/|features/santri/dashboard/presentation/providers/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/dashboard/presentation/widgets/|features/santri/dashboard/presentation/widgets/|g' {} +

# Santri features - presensi, profile, leaderboard
find lib -type f -name "*.dart" -exec sed -i \
  's|features/presensi/|features/santri/presensi/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/profile/|features/santri/profile/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/leaderboard/|features/santri/leaderboard/|g' {} +

echo "✅ Santri imports updated"
echo ""

echo "🔄 Phase 3: Updating Dewan Guru Feature Imports..."
echo "---------------------------------------------------"

# Dewan Guru features
find lib -type f -name "*.dart" -exec sed -i \
  's|features/dashboard/presentation/pages/dewan_guru_dashboard_page|features/dewan_guru/dashboard/presentation/pages/dewan_guru_dashboard_page|g' {} +

echo "✅ Dewan Guru imports updated"
echo ""

echo "🔄 Phase 4: Updating Shared Feature Imports..."
echo "-----------------------------------------------"

# Shared features
find lib -type f -name "*.dart" -exec sed -i \
  's|features/auth/|features/shared/auth/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/jadwal/|features/shared/jadwal/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/pengumuman/|features/shared/pengumuman/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/calendar/|features/shared/calendar/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/notifications/|features/shared/notifications/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/help/|features/shared/help/|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's|features/settings/|features/shared/settings/|g' {} +

echo "✅ Shared imports updated"
echo ""

echo "🔄 Phase 5: Updating Class References..."
echo "-----------------------------------------"

# Update class names
find lib -type f -name "*.dart" -exec sed -i \
  's|const DashboardPage()|const SantriDashboardPage()|g' {} +
find lib -type f -name "*.dart" -exec sed -i \
  's| DashboardPage()| SantriDashboardPage()|g' {} +

echo "✅ Class references updated"
echo ""

echo "📊 Running Flutter Analyze..."
echo "------------------------------"
flutter analyze 2>&1 | head -50

echo ""
echo "✅ Migration script completed!"
echo "==============================="
echo ""
echo "Next steps:"
echo "1. Review flutter analyze output above"
echo "2. Fix any remaining errors manually"
echo "3. Test app: flutter run"
echo "4. If all works, delete old folders"
echo ""
