import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Dialog untuk menambah user baru
class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  AddUserDialogState createState() => AddUserDialogState();
}

class AddUserDialogState extends State<AddUserDialog> {
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
        'recordedBy': 'Admin',
      });

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
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
