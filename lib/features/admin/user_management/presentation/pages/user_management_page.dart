import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/shared/models/user_model.dart';
import 'package:sisantri/features/admin/user_management/presentation/pages/user_detail_page.dart';
import 'package:sisantri/features/admin/user_management/presentation/providers/user_providers.dart';
import 'package:sisantri/features/admin/user_management/presentation/widgets/user_stats_section.dart';
import 'package:sisantri/features/admin/user_management/presentation/widgets/user_search_bar.dart';
import 'package:sisantri/features/admin/user_management/presentation/widgets/user_card.dart';
import 'package:sisantri/features/admin/user_management/presentation/widgets/add_user_dialog.dart';

/// Halaman Manajemen User
class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Semua'),
            Tab(icon: Icon(Icons.school), text: 'Santri'),
            Tab(icon: Icon(Icons.person_outline), text: 'Guru'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allUsersProvider);
          ref.invalidate(userStatsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            // Statistics Section
            statsAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SizedBox.shrink(),
              data: (stats) => UserStatsSection(stats: stats),
            ),

            // Search Section
            UserSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),

            // Users List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersList(usersAsync, 'all'),
                  _buildUsersList(usersAsync, 'santri'),
                  _buildUsersList(usersAsync, 'guru'),
                  _buildUsersList(usersAsync, 'admin'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah User'),
      ),
    );
  }

  Widget _buildUsersList(
    AsyncValue<List<UserModel>> usersAsync,
    String filter,
  ) {
    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allUsersProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: (users) {
        final filteredUsers = _filterUsers(users, filter);

        if (filteredUsers.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada user yang sesuai dengan pencarian'
                          : 'Belum ada user untuk kategori ini',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return UserCard(
              user: user,
              onTap: () => _navigateToUserDetail(user),
            );
          },
        );
      },
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users, String filter) {
    List<UserModel> filtered;

    // Filter by role
    switch (filter) {
      case 'santri':
        filtered = users.where((u) => u.isSantri).toList();
        break;
      case 'guru':
        filtered = users.where((u) => u.isDewaGuru).toList();
        break;
      case 'admin':
        filtered = users.where((u) => u.isAdmin).toList();
        break;
      default:
        filtered = users;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.nama.toLowerCase().contains(_searchQuery) ||
            user.email.toLowerCase().contains(_searchQuery) ||
            (user.nim?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _navigateToUserDetail(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
    );
  }

  Future<void> _showAddUserDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddUserDialog(),
    );

    if (result == true) {
      // Refresh data after adding user
      ref.invalidate(allUsersProvider);
      ref.invalidate(userStatsProvider);
    }
  }
}
