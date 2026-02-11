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
  String? _userId;

  CartProvider();

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(
      0, (sum, item) => sum + (item.product.currentPrice * item.quantity));

  String get _storageKey => 'cart_items_${_userId ?? 'anonymous'}';

  Future<void> initForUser(String? userId) async {
    _userId = userId;
    _items.clear();
    notifyListeners();
    await _loadCart();
  }

  void addToCart(Product product) {
    var index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
    _saveCart();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    _saveCart();
  }

  void decreaseQuantity(String productId) {
    var index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      _saveCart();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  Future<void> _saveCart() async {
    final key = _storageKey;
    // Create a copy of items to avoid race conditions if _items is modified/cleared
    // while waiting for SharedPreferences
    final itemsToSave = List<CartItem>.from(_items);

    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(itemsToSave.map((e) => e.toJson()).toList());
    await prefs.setString(key, encodedData);
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
