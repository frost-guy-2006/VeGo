import 'package:flutter/foundation.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for managing user's wishlist/favorites
class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlist = [];
  String? _currentUserId;

  List<Product> get wishlist => List.unmodifiable(_wishlist);
  int get itemCount => _wishlist.length;

  String get _storageKey {
    return _currentUserId == null
        ? 'user_wishlist_anonymous'
        : 'user_wishlist_$_currentUserId';
  }

  /// Initialize provider for a specific user
  Future<void> initForUser(String? userId) async {
    _wishlist.clear();
    _currentUserId = userId;
    await loadFromStorage();
    notifyListeners();
  }

  /// Check if a product is in the wishlist
  bool isInWishlist(String productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  /// Toggle a product in/out of wishlist
  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    _saveToStorage(List.from(_wishlist), _currentUserId);
    notifyListeners();
  }

  /// Add a product to wishlist
  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      _wishlist.add(product);
      _saveToStorage(List.from(_wishlist), _currentUserId);
      notifyListeners();
    }
  }

  /// Remove a product from wishlist
  void removeFromWishlist(String productId) {
    _wishlist.removeWhere((p) => p.id == productId);
    _saveToStorage(List.from(_wishlist), _currentUserId);
    notifyListeners();
  }

  /// Clear entirewishlist
  void clearWishlist() {
    _wishlist.clear();
    _saveToStorage(List.from(_wishlist), _currentUserId);
    notifyListeners();
  }

  /// Load wishlist from persistent storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(_storageKey);

      if (wishlistJson != null) {
        final List<dynamic> decoded = json.decode(wishlistJson);
        _wishlist.clear();
        _wishlist.addAll(decoded.map((item) => Product.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist from storage: $e');
    }
  }

  /// Save wishlist to persistent storage
  Future<void> _saveToStorage(List<Product> wishlist, String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson =
          json.encode(wishlist.map((p) => p.toJson()).toList());
      final key = userId == null ? 'user_wishlist_anonymous' : 'user_wishlist_$userId';
      await prefs.setString(key, wishlistJson);
    } catch (e) {
      debugPrint('Error saving wishlist to storage: $e');
    }
  }
}
