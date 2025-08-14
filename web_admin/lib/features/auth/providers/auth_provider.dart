import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/auth.dart';
import '../../shared/services/auth_service.dart';

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isLoggedIn => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(user: user, isLoading: false, error: null);
      } else {
        state = state.copyWith(user: null, isLoading: false, error: null);
      }
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false, error: e.toString());
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.login(username, password);
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(user: null, isLoading: false, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});