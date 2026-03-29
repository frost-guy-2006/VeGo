import 'package:flutter/foundation.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for managing user's wishlist/favorites
class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlist = [];
  String? _userId;

  List<Product> get wishlist => List.unmodifiable(_wishlist);
  int get itemCount => _wishlist.length;

  String get _storageKey => 'wishlist_${_userId ?? 'anonymous'}';

  Future<void> initForUser(String? userId) async {
    _userId = userId;
    _wishlist.clear();
    notifyListeners();
    await loadFromStorage();
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
    _saveToStorage();
    notifyListeners();
  }

  /// Add a product to wishlist
  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      _wishlist.add(product);
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Remove a product from wishlist
  void removeFromWishlist(String productId) {
    _wishlist.removeWhere((p) => p.id == productId);
    _saveToStorage();
    notifyListeners();
  }

  /// Clear entirewishlist
  void clearWishlist() {
    _wishlist.clear();
    _saveToStorage();
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
  Future<void> _saveToStorage() async {
    final key = _storageKey;
    final wishlistToSave = List<Product>.from(_wishlist);
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson =
          json.encode(wishlistToSave.map((p) => p.toJson()).toList());
      await prefs.setString(key, wishlistJson);
    } catch (e) {
      debugPrint('Error saving wishlist to storage: $e');
    }
  }
}
