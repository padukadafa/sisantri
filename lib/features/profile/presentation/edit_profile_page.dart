import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';

/// Provider untuk loading state
final editProfileLoadingProvider = StateProvider<bool>((ref) => false);

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nimController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _kampusController = TextEditingController();

  File? _selectedImage;
  final _picker = ImagePicker();

  String? _selectedKampus;
  String? _selectedTempatKos;

  @override
  void initState() {
    super.initState();

    // Initialize form fields with user data
    _namaController.text = widget.user.nama;
    _emailController.text = widget.user.email;
    _nimController.text = widget.user.nim ?? '';
    _jurusanController.text = widget.user.jurusan ?? '';

    // Initialize dropdown selections
    _selectedKampus = widget.user.kampus;
    _selectedTempatKos = widget.user.tempatKos;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _jurusanController.dispose();
    _kampusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(editProfileLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(),
                const SizedBox(height: 32),

                // Form Fields
                _buildFormSection(),
                const SizedBox(height: 32),

                // RFID Info Section
                _buildRfidInfoSection(),

                const SizedBox(height: 40),

                // Save Button
                _buildSaveButton(isLoading),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 57,
                  backgroundImage: _getProfileImage(),
                  backgroundColor: Colors.grey[100],
                  child: _getProfileImage() == null
                      ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _showImagePickerDialog,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.nama,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          widget.user.email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (widget.user.fotoProfil != null) {
      return NetworkImage(widget.user.fotoProfil!);
    }
    return null;
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Foto Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null || widget.user.fotoProfil != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        // Nama
        TextFormField(
          controller: _namaController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
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

        const SizedBox(height: 20),

        // Email (read-only)
        TextFormField(
          controller: _emailController,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
            helperText: 'Email tidak dapat diubah',
          ),
        ),

        const SizedBox(height: 20),

        // NIM
        TextFormField(
          controller: _nimController,
          decoration: const InputDecoration(
            labelText: 'NIM (Opsional)',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
            hintText: 'Masukkan NIM Anda',
          ),
        ),

        const SizedBox(height: 20),

        // Jurusan Text Field
        SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: _jurusanController,
            decoration: const InputDecoration(
              labelText: 'Jurusan',
              hintText: 'Masukkan nama jurusan',
              prefixIcon: Icon(Icons.school),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Jurusan tidak boleh kosong';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 20),

        // Kampus Dropdown
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _selectedKampus,
            decoration: const InputDecoration(
              labelText: 'Kampus',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
              hintText: 'Pilih kampus',
            ),
            isExpanded: true,
            items: UserModel.kampusPilihan.map((kampus) {
              return DropdownMenuItem(
                value: kampus,
                child: Text(kampus, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKampus = value;
                if (value != 'Lainnya') {
                  _kampusController.text = value ?? '';
                } else {
                  _kampusController.clear();
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih kampus Anda';
              }
              return null;
            },
          ),
        ),
        if (_selectedKampus == 'Lainnya') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _kampusController,
            decoration: const InputDecoration(
              labelText: 'Nama Kampus Lainnya',
              hintText: 'Masukkan nama kampus',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_selectedKampus == 'Lainnya' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Nama kampus harus diisi';
              }
              return null;
            },
          ),
        ],

        const SizedBox(height: 20),

        // Tempat Kos Dropdown
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _selectedTempatKos,
            decoration: const InputDecoration(
              labelText: 'Tempat Kos',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
              hintText: 'Pilih tempat kos',
            ),
            isExpanded: true,
            items: UserModel.tempatKosPilihan.map((tempat) {
              return DropdownMenuItem(
                value: tempat,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(UserModel.getTempatKosIcon(tempat)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tempat, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTempatKos = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih tempat kos Anda';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRfidInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contactless, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'RFID Card Info',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.user.hasRfidSetup
                ? 'Card ID: ${widget.user.rfidCardId}'
                : 'RFID belum di-setup',
            style: TextStyle(color: Colors.green[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(editProfileLoadingProvider.notifier).state = true;

    try {
      // Prepare update data
      final Map<String, dynamic> updateData = {
        'nama': _namaController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add NIM if filled
      if (_nimController.text.trim().isNotEmpty) {
        updateData['nim'] = _nimController.text.trim();
      }

      // Add Jurusan
      if (_jurusanController.text.trim().isNotEmpty) {
        updateData['jurusan'] = _jurusanController.text.trim();
      }

      // Add Kampus
      if (_selectedKampus != null) {
        if (_selectedKampus == 'Lainnya') {
          updateData['kampus'] = _kampusController.text.trim();
        } else {
          updateData['kampus'] = _selectedKampus;
        }
      }

      // Add Tempat Kos
      if (_selectedTempatKos != null) {
        updateData['tempatKos'] = _selectedTempatKos;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update(updateData);

      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profil berhasil diperbarui'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal memperbarui profil: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(editProfileLoadingProvider.notifier).state = false;
      }
    }
  }
}
