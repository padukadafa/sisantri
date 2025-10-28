import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/shared/models/user_model.dart';

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

/// Provider untuk user yang difilter berdasarkan role
final filteredUsersProvider = Provider.family<List<UserModel>, String>((
  ref,
  role,
) {
  final users = ref.watch(allUsersProvider).asData?.value ?? [];

  if (role == 'all') return users;

  switch (role) {
    case 'santri':
      return users.where((u) => u.isSantri).toList();
    case 'guru':
      return users.where((u) => u.isDewaGuru).toList();
    case 'admin':
      return users.where((u) => u.isAdmin).toList();
    case 'active':
      return users.where((u) => u.statusAktif).toList();
    case 'inactive':
      return users.where((u) => !u.statusAktif).toList();
    default:
      return users;
  }
});
