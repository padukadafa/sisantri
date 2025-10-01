import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';
import 'providers/user_management_providers.dart';
import 'widgets/user_stats_card.dart';
import 'widgets/user_filter_bar.dart';
import 'widgets/user_list_item.dart';
import 'services/user_management_service.dart';

/// User Management Page yang sudah dipecah menjadi komponen kecil
class UserManagementPageClean extends ConsumerStatefulWidget {
  const UserManagementPageClean({super.key});

  @override
  ConsumerState<UserManagementPageClean> createState() =>
      _UserManagementPageCleanState();
}

class _UserManagementPageCleanState
    extends ConsumerState<UserManagementPageClean> {
  final UserManagementService _userService = UserManagementService();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserDialog,
            tooltip: 'Tambah Pengguna',
          ),
        ],
      ),
      body: Column(
        children: [
          const UserStatsCard(),

          UserFilterBar(
            selectedFilter: _selectedFilter,
            searchQuery: _searchQuery,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (users) => _buildUserList(_filterUsers(users)),
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    var filteredUsers = users;

    // Filter by role/status
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'santri':
          filteredUsers = users.where((u) => u.isSantri).toList();
          break;
        case 'guru':
          filteredUsers = users.where((u) => u.isDewaGuru).toList();
          break;
        case 'admin':
          filteredUsers = users.where((u) => u.isAdmin).toList();
          break;
        case 'active':
          filteredUsers = users.where((u) => u.statusAktif).toList();
          break;
        case 'inactive':
          filteredUsers = users.where((u) => !u.statusAktif).toList();
          break;
      }
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers
          .where(
            (u) =>
                u.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filteredUsers;
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada pengguna ditemukan',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListItem(
          user: user,
          onTap: () => _showUserDetail(user),
          onEdit: () => _showEditUserDialog(user),
          onDelete: () => _confirmDeleteUser(user),
          onToggleStatus: () => _toggleUserStatus(user),
        );
      },
    );
  }

  void _showUserDetail(UserModel user) {
    // Navigate to user detail page
    // Navigator.push(context, MaterialPageRoute(...));
  }

  void _showAddUserDialog() {
    // Show add user dialog
    // showDialog(context: context, builder: ...);
  }

  void _showEditUserDialog(UserModel user) {
    // Show edit user dialog
    // showDialog(context: context, builder: ...);
  }

  void _confirmDeleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.nama} berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _toggleUserStatus(UserModel user) async {
    try {
      await _userService.toggleUserStatus(user.id, user.statusAktif);
      if (mounted) {
        final status = user.statusAktif ? 'dinonaktifkan' : 'diaktifkan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.nama} berhasil $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
