import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Authentication failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Verification failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Sign in failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Sign up failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
