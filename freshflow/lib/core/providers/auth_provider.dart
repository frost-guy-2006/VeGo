import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  AuthProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      rethrow;
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
