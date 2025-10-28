import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/features/shared/auth/domain/entities/user.dart';
import 'package:sisantri/features/shared/auth/domain/usecases/login_with_email_and_password.dart';
import 'package:sisantri/features/shared/auth/domain/usecases/get_current_user.dart';
import 'package:sisantri/features/shared/auth/domain/usecases/logout.dart';
import 'package:sisantri/core/di/injection.dart';
import 'package:sisantri/core/utils/result.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithEmailAndPassword _loginUseCase;
  final GetCurrentUser _getCurrentUserUseCase;
  final Logout _logoutUseCase;

  AuthNotifier({
    required LoginWithEmailAndPassword loginUseCase,
    required GetCurrentUser getCurrentUserUseCase,
    required Logout logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthState());

  Future<void> checkCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCurrentUserUseCase();

    result.fold(
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
      onError: (failure) {
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: failure.message,
        );
      },
    );
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
      onError: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await Future.any([
        _logoutUseCase(),
        Future.delayed(const Duration(seconds: 10), () {
          throw Exception('Timeout: Logout terlalu lama');
        }),
      ]);

      result.fold(
        onSuccess: (_) {
          state = state.copyWith(user: null, isLoading: false);
        },
        onError: (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
      );
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.read(loginWithEmailAndPasswordProvider),
    getCurrentUserUseCase: ref.read(getCurrentUserProvider),
    logoutUseCase: ref.read(logoutProvider),
  );
});
