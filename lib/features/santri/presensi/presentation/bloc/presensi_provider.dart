import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/presensi.dart';
import '../../domain/usecases/add_presensi.dart';
import '../../domain/usecases/get_presensi_by_user_id.dart';
import '../../domain/usecases/presensi_with_rfid.dart';
import 'package:sisantri/core/di/injection.dart';
import 'package:sisantri/core/utils/result.dart';

/// Presensi State
class PresensiState {
  final List<Presensi> presensiList;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const PresensiState({
    this.presensiList = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  PresensiState copyWith({
    List<Presensi>? presensiList,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return PresensiState(
      presensiList: presensiList ?? this.presensiList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Presensi Notifier
class PresensiNotifier extends StateNotifier<PresensiState> {
  final AddPresensi _addPresensiUseCase;
  final GetPresensiByUserId _getPresensiByUserIdUseCase;
  final PresensiWithRfid _presensiWithRfidUseCase;

  PresensiNotifier({
    required AddPresensi addPresensiUseCase,
    required GetPresensiByUserId getPresensiByUserIdUseCase,
    required PresensiWithRfid presensiWithRfidUseCase,
  }) : _addPresensiUseCase = addPresensiUseCase,
       _getPresensiByUserIdUseCase = getPresensiByUserIdUseCase,
       _presensiWithRfidUseCase = presensiWithRfidUseCase,
       super(const PresensiState());

  /// Load presensi by user ID
  Future<void> loadPresensiByUserId(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getPresensiByUserIdUseCase(userId);

    result.fold(
      onSuccess: (presensiList) {
        state = state.copyWith(presensiList: presensiList, isLoading: false);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  /// Add presensi
  Future<void> addPresensi(Presensi presensi) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _addPresensiUseCase(presensi);

    result.fold(
      onSuccess: (newPresensi) {
        final updatedList = [newPresensi, ...state.presensiList];
        state = state.copyWith(
          presensiList: updatedList,
          isLoading: false,
          successMessage: 'Presensi berhasil ditambahkan',
        );
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  /// Presensi dengan RFID
  Future<void> presensiWithRfid({
    required String rfidCardId,
    required DateTime tanggal,
    String? keterangan,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _presensiWithRfidUseCase(
      rfidCardId: rfidCardId,
      tanggal: tanggal,
      keterangan: keterangan,
    );

    result.fold(
      onSuccess: (newPresensi) {
        final updatedList = [newPresensi, ...state.presensiList];
        state = state.copyWith(
          presensiList: updatedList,
          isLoading: false,
          successMessage: 'Presensi RFID berhasil',
        );
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Presensi Provider
final presensiProvider = StateNotifierProvider<PresensiNotifier, PresensiState>(
  (ref) {
    return PresensiNotifier(
      addPresensiUseCase: ref.read(addPresensiProvider),
      getPresensiByUserIdUseCase: ref.read(getPresensiByUserIdProvider),
      presensiWithRfidUseCase: ref.read(presensiWithRfidProvider),
    );
  },
);
