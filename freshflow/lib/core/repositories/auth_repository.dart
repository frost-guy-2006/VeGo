import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/app_error.dart';

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
      throw AppError.from(e);
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
      throw AppError.from(e);
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
      throw AppError.from(e);
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
      throw AppError.from(e);
    }
  }

  /// Update user profile data in the profiles table
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('profiles').upsert({
        'id': userId,
        ...updates,
      });
    } catch (e) {
      debugPrint('AuthRepository: Error updating profile: $e');
      throw AppError.from(e);
    }
  }

  /// Fetch user profile from profiles table
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('AuthRepository: Error fetching profile: $e');
      throw AppError.from(e);
    }
  }

  /// Update user auth metadata (display name, avatar URL)
  Future<void> updateAuthMetadata({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      await _client.auth.updateUser(UserAttributes(data: data));
    } catch (e) {
      debugPrint('AuthRepository: Error updating auth metadata: $e');
      throw AppError.from(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('AuthRepository: Error signing out: $e');
      throw AppError.from(e);
    }
  }
}
