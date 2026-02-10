import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _currentUserId;

  CartProvider() {
    _loadCart();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  /// Initialize provider with current user's data.
  Future<void> initForUser(String? userId) async {
    _items.clear();
    _currentUserId = userId;
    await _loadCart();
    notifyListeners();
  }

  double get totalPrice => _items.fold(
      0, (sum, item) => sum + (item.product.currentPrice * item.quantity));

  Future<void> addToCart(Product product) async {
    var index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
    await _saveCart();
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await _saveCart();
  }

  Future<void> decreaseQuantity(String productId) async {
    var index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      await _saveCart();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }

  String get _storageKey {
    if (_currentUserId == null) {
      return 'cart_items_anonymous';
    }
    return 'cart_items_$_currentUserId';
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _items = decodedData.map((e) => CartItem.fromJson(e)).toList();
      notifyListeners();
    }
  }
}
