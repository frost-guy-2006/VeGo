import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';

/// Cart item with product and quantity.
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

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

/// Cart state with immutable list of items.
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalPrice => items.fold(
      0, (sum, item) => sum + (item.product.currentPrice * item.quantity));

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

/// Cart notifier for Riverpod.
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _loadCart();
  }

  void addToCart(Product product) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product));
    }

    state = state.copyWith(items: items);
    _saveCart();
  }

  void removeFromCart(String productId) {
    final items =
        state.items.where((item) => item.product.id != productId).toList();
    state = state.copyWith(items: items);
    _saveCart();
  }

  void decreaseQuantity(String productId) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index] =
            items[index].copyWith(quantity: items[index].quantity - 1);
      } else {
        items.removeAt(index);
      }
      state = state.copyWith(items: items);
      _saveCart();
    }
  }

  void clearCart() {
    state = const CartState();
    _saveCart();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString('cart_items', encodedData);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString('cart_items');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      final items = decodedData.map((e) => CartItem.fromJson(e)).toList();
      state = state.copyWith(items: items);
    }
  }
}

/// Riverpod provider for cart state.
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
