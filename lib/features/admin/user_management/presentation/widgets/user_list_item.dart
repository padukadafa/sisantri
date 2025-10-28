import 'package:flutter/material.dart';
import 'package:sisantri/shared/models/user_model.dart';

/// Widget untuk menampilkan single user item dalam list
class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const UserListItem({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(),
          child: Text(
            user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.nama,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(),
                const SizedBox(width: 8),
                _buildStatusChip(),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'toggle_status':
                onToggleStatus?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
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
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    user.statusAktif ? Icons.block : Icons.check_circle,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(user.statusAktif ? 'Nonaktifkan' : 'Aktifkan'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
        isThreeLine: true,
      ),
    );
  }

  Color _getRoleColor() {
    if (user.isAdmin) return Colors.orange;
    if (user.isDewaGuru) return Colors.purple;
    if (user.isSantri) return Colors.green;
    return Colors.grey;
  }

  Widget _buildRoleChip() {
    String roleText;
    Color roleColor;

    if (user.isAdmin) {
      roleText = 'Admin';
      roleColor = Colors.orange;
    } else if (user.isDewaGuru) {
      roleText = 'Guru';
      roleColor = Colors.purple;
    } else if (user.isSantri) {
      roleText = 'Santri';
      roleColor = Colors.green;
    } else {
      roleText = 'Unknown';
      roleColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roleText,
        style: TextStyle(
          color: roleColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: user.statusAktif
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.statusAktif ? 'Aktif' : 'Tidak Aktif',
        style: TextStyle(
          color: user.statusAktif ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
