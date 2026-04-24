import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _repository.currentUser;
  bool get isAuthenticated => _repository.isAuthenticated;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _repository.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.signInWithPhone(phoneNumber);
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

      await _repository.verifyOtp(phoneNumber, otp);
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

      await _repository.signInWithEmail(email, password);
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

      await _repository.signUpWithEmail(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    notifyListeners();
  }
}

