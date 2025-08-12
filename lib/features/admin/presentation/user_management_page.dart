import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/user_model.dart';

/// Provider untuk daftar semua users
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('nama')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList();
      });
});

/// Provider untuk statistik users
final userStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final users = await ref.watch(allUsersProvider.future);

  return {
    'total': users.length,
    'santri': users.where((u) => u.isSantri).length,
    'guru': users.where((u) => u.isDewaGuru).length,
    'admin': users.where((u) => u.isAdmin).length,
    'active': users.where((u) => u.statusAktif).length,
    'inactive': users.where((u) => !u.statusAktif).length,
  };
});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(),
            tooltip: 'Tambah User',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(allUsersProvider);
              ref.invalidate(userStatsProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Semua'),
            Tab(icon: Icon(Icons.school), text: 'Santri'),
            Tab(icon: Icon(Icons.person_outline), text: 'Dewan Guru'),
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
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SizedBox.shrink(),
              data: (stats) => _buildStatsSection(stats),
            ),

            // Search and Filter Section
            _buildSearchSection(),

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
    );
  }

  Widget _buildStatsSection(Map<String, int> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total User',
              stats['total']!,
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Aktif',
              stats['active']!,
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Non-Aktif',
              stats['inactive']!,
              Icons.cancel,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama, NIM, atau email...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
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
            child: Container(
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
            return _buildUserCard(user);
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

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showUserDetailDialog(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRoleColor(user).withOpacity(0.1),
                    child: Text(
                      user.nama.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: _getRoleColor(user),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getRoleColor(user).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getRoleText(user),
                          style: TextStyle(
                            color: _getRoleColor(user),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.statusAktif
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.statusAktif ? 'Aktif' : 'Non-Aktif',
                          style: TextStyle(
                            color: user.statusAktif ? Colors.green : Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(value, user),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 8),
                            Text('Lihat Detail'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: user.statusAktif ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              user.statusAktif
                                  ? Icons.block
                                  : Icons.check_circle,
                              size: 16,
                              color: user.statusAktif
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.statusAktif ? 'Non-aktifkan' : 'Aktifkan',
                              style: TextStyle(
                                color: user.statusAktif
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reset_password',
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_reset,
                              size: 16,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Reset Password',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                      if (!user.isAdmin)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (user.nim != null) ...[
                    Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'NIM: ${user.nim}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (user.kampus != null) ...[
                    Icon(Icons.school, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.kampus!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (user.tempatKos != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.home, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Kos: ${user.tempatKos}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserModel user) {
    if (user.isAdmin) return Colors.red;
    if (user.isDewaGuru) return Colors.orange;
    if (user.isSantri) return Colors.blue;
    return Colors.grey;
  }

  String _getRoleText(UserModel user) {
    if (user.isAdmin) return 'ADMIN';
    if (user.isDewaGuru) return 'GURU';
    if (user.isSantri) return 'SANTRI';
    return 'USER';
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetailDialog(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetailDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail User: ${user.nama}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama', user.nama),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', _getRoleText(user)),
              _buildDetailRow(
                'Status',
                user.statusAktif ? 'Aktif' : 'Non-Aktif',
              ),
              if (user.nim != null) _buildDetailRow('NIM', user.nim!),
              if (user.kampus != null) _buildDetailRow('Kampus', user.kampus!),
              if (user.tempatKos != null)
                _buildDetailRow('Tempat Kos', user.tempatKos!),
              if (user.createdAt != null)
                _buildDetailRow('Dibuat', _formatDateTime(user.createdAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditUserDialog(user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(user: user),
    );
  }

  void _showAddUserDialog() {
    showDialog(context: context, builder: (context) => _AddUserDialog());
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.statusAktif ? 'Non-aktifkan' : 'Aktifkan'} User'),
        content: Text(
          'Apakah Anda yakin ingin ${user.statusAktif ? 'menonaktifkan' : 'mengaktifkan'} user "${user.nama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.statusAktif ? Colors.red : Colors.green,
            ),
            child: Text(user.statusAktif ? 'Non-aktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({'statusAktif': !user.statusAktif});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User ${user.nama} berhasil ${user.statusAktif ? 'dinonaktifkan' : 'diaktifkan'}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _resetUserPassword(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'Apakah Anda yakin ingin reset password untuk user "${user.nama}"?\n\nPassword akan direset ke default.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement password reset logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur reset password sedang dalam pengembangan'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text(
          'Apakah Anda yakin ingin menghapus user "${user.nama}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${user.nama} berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}

/// Dialog untuk menambah user baru
class _AddUserDialog extends StatefulWidget {
  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nimController = TextEditingController();
  final _kampusController = TextEditingController();
  final _tempatKosController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'santri';
  bool _statusAktif = true;
  bool _isLoading = false;
  bool _showPassword = false;

  final List<String> _roleOptions = ['santri', 'dewan_guru', 'admin'];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _kampusController.dispose();
    _tempatKosController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah User Baru'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: _roleOptions.map((role) {
                    String displayName;
                    IconData icon;
                    Color color;

                    switch (role) {
                      case 'santri':
                        displayName = 'Santri';
                        icon = Icons.school;
                        color = Colors.blue;
                        break;
                      case 'dewan_guru':
                        displayName = 'Dewan Guru';
                        icon = Icons.person_outline;
                        color = Colors.orange;
                        break;
                      case 'admin':
                        displayName = 'Admin';
                        icon = Icons.admin_panel_settings;
                        color = Colors.red;
                        break;
                      default:
                        displayName = role;
                        icon = Icons.person;
                        color = Colors.grey;
                    }

                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // NIM (untuk santri)
                if (_selectedRole == 'santri') ...[
                  TextFormField(
                    controller: _nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: _selectedRole == 'santri'
                        ? (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 5) {
                              return 'NIM minimal 5 karakter';
                            }
                            return null;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Kampus
                  TextFormField(
                    controller: _kampusController,
                    decoration: const InputDecoration(
                      labelText: 'Kampus',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tempat Kos
                  TextFormField(
                    controller: _tempatKosController,
                    decoration: const InputDecoration(
                      labelText: 'Tempat Kos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Status Aktif
                Row(
                  children: [
                    const Text('Status Aktif:'),
                    const Spacer(),
                    Switch(
                      value: _statusAktif,
                      onChanged: (value) {
                        setState(() {
                          _statusAktif = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  '* Field wajib diisi',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email sudah digunakan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create user data
      final userData = {
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'statusAktif': _statusAktif,
        'poin': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields for santri
      if (_selectedRole == 'santri') {
        if (_nimController.text.trim().isNotEmpty) {
          userData['nim'] = _nimController.text.trim();
        }
        if (_kampusController.text.trim().isNotEmpty) {
          userData['kampus'] = _kampusController.text.trim();
        }
        if (_tempatKosController.text.trim().isNotEmpty) {
          userData['tempatKos'] = _tempatKosController.text.trim();
        }
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').add(userData);

      // Log activity
      await FirebaseFirestore.instance.collection('activities').add({
        'type': 'user_created',
        'title': 'User Baru Ditambahkan',
        'description':
            'User baru "${_namaController.text.trim()}" dengan role ${_getRoleDisplayName(_selectedRole)} berhasil ditambahkan',
        'timestamp': FieldValue.serverTimestamp(),
        'recordedBy': 'Admin', // TODO: Get actual admin ID
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${_namaController.text.trim()} berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'santri':
        return 'Santri';
      case 'dewan_guru':
        return 'Dewan Guru';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

/// Dialog untuk edit user
class _EditUserDialog extends StatefulWidget {
  final UserModel user;

  const _EditUserDialog({required this.user});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _nimController;
  late final TextEditingController _kampusController;
  late final TextEditingController _tempatKosController;

  late String _selectedRole;
  late bool _statusAktif;
  bool _isLoading = false;

  final List<String> _roleOptions = ['santri', 'dewan_guru', 'admin'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _emailController = TextEditingController(text: widget.user.email);
    _nimController = TextEditingController(text: widget.user.nim ?? '');
    _kampusController = TextEditingController(text: widget.user.kampus ?? '');
    _tempatKosController = TextEditingController(
      text: widget.user.tempatKos ?? '',
    );
    _selectedRole = widget.user.role;
    _statusAktif = widget.user.statusAktif;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _kampusController.dispose();
    _tempatKosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User: ${widget.user.nama}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: _roleOptions.map((role) {
                    String displayName;
                    IconData icon;
                    Color color;

                    switch (role) {
                      case 'santri':
                        displayName = 'Santri';
                        icon = Icons.school;
                        color = Colors.blue;
                        break;
                      case 'dewan_guru':
                        displayName = 'Dewan Guru';
                        icon = Icons.person_outline;
                        color = Colors.orange;
                        break;
                      case 'admin':
                        displayName = 'Admin';
                        icon = Icons.admin_panel_settings;
                        color = Colors.red;
                        break;
                      default:
                        displayName = role;
                        icon = Icons.person;
                        color = Colors.grey;
                    }

                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // NIM (untuk santri)
                if (_selectedRole == 'santri') ...[
                  TextFormField(
                    controller: _nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: _selectedRole == 'santri'
                        ? (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 5) {
                              return 'NIM minimal 5 karakter';
                            }
                            return null;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Kampus
                  TextFormField(
                    controller: _kampusController,
                    decoration: const InputDecoration(
                      labelText: 'Kampus',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tempat Kos
                  TextFormField(
                    controller: _tempatKosController,
                    decoration: const InputDecoration(
                      labelText: 'Tempat Kos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Status Aktif
                Row(
                  children: [
                    const Text('Status Aktif:'),
                    const Spacer(),
                    Switch(
                      value: _statusAktif,
                      onChanged: (value) {
                        setState(() {
                          _statusAktif = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  '* Field wajib diisi',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists (excluding current user)
      if (_emailController.text.trim() != widget.user.email) {
        final existingUser = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (existingUser.docs.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email sudah digunakan'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Update user data
      final userData = <String, dynamic>{
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'statusAktif': _statusAktif,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Handle optional fields for santri
      if (_selectedRole == 'santri') {
        userData['nim'] = _nimController.text.trim().isNotEmpty
            ? _nimController.text.trim()
            : null;
        userData['kampus'] = _kampusController.text.trim().isNotEmpty
            ? _kampusController.text.trim()
            : null;
        userData['tempatKos'] = _tempatKosController.text.trim().isNotEmpty
            ? _tempatKosController.text.trim()
            : null;
      } else {
        // Remove santri-specific fields if role changed
        userData['nim'] = FieldValue.delete();
        userData['kampus'] = FieldValue.delete();
        userData['tempatKos'] = FieldValue.delete();
      }

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update(userData);

      // Log activity
      await FirebaseFirestore.instance.collection('activities').add({
        'type': 'user_updated',
        'title': 'User Diupdate',
        'description':
            'User "${_namaController.text.trim()}" berhasil diupdate',
        'timestamp': FieldValue.serverTimestamp(),
        'recordedBy': 'Admin', // TODO: Get actual admin ID
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${_namaController.text.trim()} berhasil diupdate',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
