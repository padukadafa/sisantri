import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';

/// Provider untuk loading state
final editProfileLoadingProvider = StateProvider<bool>((ref) => false);

/// Halaman Edit Profile
class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nimController = TextEditingController();
  final _fakultasController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _namaController.text = widget.user.nama;
    _emailController.text = widget.user.email;
    // TODO: Add NIM and Fakultas fields to UserModel
    // _nimController.text = widget.user.nim ?? '';
    // _fakultasController.text = widget.user.fakultas ?? '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _fakultasController.dispose();
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
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveProfile,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: isLoading ? Colors.grey : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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

              // RFID Info (if exists)
              if (widget.user.hasRfidSetup) _buildRfidInfoSection(),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
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
              ),
              child: CircleAvatar(
                radius: 57,
                backgroundColor: Colors.grey[100],
                backgroundImage: _getProfileImage(),
                child: _getProfileImage() == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: IconButton(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tap untuk mengubah foto profil',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
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

        // Email (readonly)
        TextFormField(
          controller: _emailController,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            suffixIcon: Icon(Icons.lock_outline, size: 20),
          ),
        ),

        const SizedBox(height: 20),

        // NIM
        TextFormField(
          controller: _nimController,
          decoration: const InputDecoration(
            labelText: 'NIM (Opsional)',
            prefixIcon: Icon(Icons.school_outlined),
            hintText: 'Masukkan Nomor Induk Mahasiswa',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 8) {
              return 'NIM minimal 8 karakter';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Fakultas
        TextFormField(
          controller: _fakultasController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Fakultas (Opsional)',
            prefixIcon: Icon(Icons.business_outlined),
            hintText: 'Masukkan nama fakultas',
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
            'Card ID: ${widget.user.rfidCardId}',
            style: TextStyle(
              color: Colors.green[700],
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: Aktif untuk presensi otomatis',
            style: TextStyle(color: Colors.green[600], fontSize: 12),
          ),
        ],
      ),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_selectedImage != null || widget.user.fotoProfil != null)
                    _buildImageSourceOption(
                      icon: Icons.delete,
                      label: 'Hapus',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _removeImage();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? AppTheme.primaryColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
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
        imageQuality: 70,
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

      // Add optional fields if filled
      if (_nimController.text.trim().isNotEmpty) {
        updateData['nim'] = _nimController.text.trim();
      }
      if (_fakultasController.text.trim().isNotEmpty) {
        updateData['fakultas'] = _fakultasController.text.trim();
      }

      // TODO: Upload image to Firebase Storage if selected
      // if (_selectedImage != null) {
      //   final imageUrl = await _uploadProfileImage(_selectedImage!);
      //   updateData['fotoProfil'] = imageUrl;
      // }

      // Update user document in Firestore
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
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(editProfileLoadingProvider.notifier).state = false;
      }
    }
  }

  // TODO: Implement image upload to Firebase Storage
  // Future<String> _uploadProfileImage(File imageFile) async {
  //   final storageRef = FirebaseStorage.instance
  //       .ref()
  //       .child('profile_images')
  //       .child('${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
  //
  //   final uploadTask = storageRef.putFile(imageFile);
  //   final snapshot = await uploadTask;
  //   final downloadUrl = await snapshot.ref.getDownloadURL();
  //
  //   return downloadUrl;
  // }
}
