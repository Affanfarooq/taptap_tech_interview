import 'package:flutter_bloc/flutter_bloc.dart';

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.username,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Simple Auth Cubit for mock authentication
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());

  Future<void> login(String username, String password) async {
    emit(state.copyWith(isLoading: true, error: null));

    await Future.delayed(const Duration(seconds: 1));

    if (username.isNotEmpty && password.length >= 4) {
      emit(
        state.copyWith(
          isAuthenticated: true,
          username: username,
          isLoading: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Invalid username or password (min 4 chars)',
        ),
      );
    }
  }

  void logout() {
    emit(AuthState());
  }
}
