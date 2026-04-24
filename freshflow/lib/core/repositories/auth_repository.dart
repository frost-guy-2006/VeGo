import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for authentication-related data operations.
/// Extracts all Supabase auth calls from the provider layer.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get the current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if a user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign in with phone number (sends OTP)
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(phone: phoneNumber);
    } catch (e) {
      debugPrint('AuthRepository: Error signing in with phone: $e');
      rethrow;
    }
  }

  /// Verify OTP for phone sign-in
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    try {
      await _client.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );
    } catch (e) {
      debugPrint('AuthRepository: Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('AuthRepository: Error signing in with email: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('AuthRepository: Error signing up: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('AuthRepository: Error signing out: $e');
      rethrow;
    }
  }
}
