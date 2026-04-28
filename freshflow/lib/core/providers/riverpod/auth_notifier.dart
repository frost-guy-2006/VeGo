import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state for Riverpod.
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? Function()? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user != null ? user() : this.user,
      error: error,
    );
  }
}

/// Auth notifier for Riverpod.
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase)
      : super(AuthState(user: _supabase.auth.currentUser)) {
    _supabase.auth.onAuthStateChange.listen((data) {
      state = state.copyWith(user: () => data.session?.user);
    });
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sign in failed');
      rethrow;
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'OTP verification failed');
      rethrow;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      state = state.copyWith(isLoading: false, user: () => _supabase.auth.currentUser);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sign in failed');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.auth.signUp(email: email, password: password);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sign up failed');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState();
  }
}

/// Riverpod provider for auth state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(Supabase.instance.client);
});
