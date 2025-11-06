import 'package:flutter/material.dart';
import 'package:sisantri/shared/models/user_model.dart';

/// Widget card untuk menampilkan item user dalam list
class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRoleColor(user).withOpacity(0.2),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Role Badge
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
                      // Status Badge
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
                      const SizedBox(height: 2),
                      // RFID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.hasRfidSetup
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.hasRfidSetup
                                  ? Icons.nfc
                                  : Icons.nfc_outlined,
                              size: 10,
                              color: user.hasRfidSetup
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              user.hasRfidSetup ? 'RFID' : 'No RFID',
                              style: TextStyle(
                                color: user.hasRfidSetup
                                    ? Colors.blue
                                    : Colors.grey,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Chevron indicator
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              // Additional info
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
}
