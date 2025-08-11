import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../admin/presentation/admin_dashboard_page.dart';
import '../../admin/presentation/manual_attendance_page.dart';
import '../../admin/presentation/schedule_management_page.dart';
import '../../admin/presentation/announcement_management_page.dart';
import '../../profile/presentation/profile_page.dart';

/// Provider untuk current tab index di admin navigation
final adminCurrentTabProvider = StateProvider<int>((ref) => 0);

/// Admin Navigation dengan Bottom Navigation Bar khusus untuk admin
class AdminNavigation extends ConsumerWidget {
  final UserModel admin;

  const AdminNavigation({super.key, required this.admin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(adminCurrentTabProvider);

    final List<Widget> pages = [
      AdminDashboardPage(admin: admin),
      const ManualAttendancePage(),
      const ScheduleManagementPage(),
      const AnnouncementManagementPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(adminCurrentTabProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg_outlined),
            activeIcon: Icon(Icons.how_to_reg),
            label: 'Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Pengumuman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
