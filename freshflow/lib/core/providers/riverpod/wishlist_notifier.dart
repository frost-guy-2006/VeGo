import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';

/// Wishlist state with immutable list of products.
class WishlistState {
  final List<Product> items;

  const WishlistState({this.items = const []});

  int get itemCount => items.length;

  bool isInWishlist(String productId) {
    return items.any((p) => p.id == productId);
  }

  WishlistState copyWith({List<Product>? items}) {
    return WishlistState(items: items ?? this.items);
  }
}

/// Wishlist notifier for Riverpod.
class WishlistNotifier extends StateNotifier<WishlistState> {
  static const String _storageKey = 'user_wishlist';

  WishlistNotifier() : super(const WishlistState()) {
    _loadFromStorage();
  }

  /// Toggle a product in/out of wishlist
  void toggleWishlist(Product product) {
    final items = [...state.items];
    final index = items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      items.removeAt(index);
    } else {
      items.add(product);
    }

    state = state.copyWith(items: items);
    _saveToStorage();
  }

  /// Add a product to wishlist
  void addToWishlist(Product product) {
    if (!state.isInWishlist(product.id)) {
      state = state.copyWith(items: [...state.items, product]);
      _saveToStorage();
    }
  }

  /// Remove a product from wishlist
  void removeFromWishlist(String productId) {
    final items = state.items.where((p) => p.id != productId).toList();
    state = state.copyWith(items: items);
    _saveToStorage();
  }

  /// Clear entire wishlist
  void clearWishlist() {
    state = const WishlistState();
    _saveToStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString(_storageKey);

      if (wishlistJson != null) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        final items = decoded.map((item) => Product.fromJson(item)).toList();
        state = state.copyWith(items: items);
      }
    } catch (e) {
      // Silent fail — wishlist is non-critical
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson =
          jsonEncode(state.items.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, wishlistJson);
    } catch (e) {
      // Silent fail
    }
  }
}

/// Riverpod provider for wishlist state.
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier();
});
