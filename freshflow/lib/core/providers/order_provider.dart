import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/order_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'dart:convert';

/// Provider for managing order history
class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  String? _currentUserId;

  List<Order> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;

  String get _storageKey {
    if (_currentUserId == null) {
      return 'order_history';
    }
    return 'order_history_$_currentUserId';
  }

  /// Initialize provider with current user's data.
  Future<void> initForUser(String? userId) async {
    if (_currentUserId != userId) {
      _orders.clear();
      _currentUserId = userId;
      await loadFromStorage();
      notifyListeners();
    }
  }

  /// Get orders sorted by most recent first
  List<Order> get recentOrders {
    final sorted = List<Order>.from(_orders);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Get active orders (not delivered or cancelled)
  List<Order> get activeOrders => _orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .toList();

  /// Get past orders (delivered or cancelled)
  List<Order> get pastOrders => _orders
      .where((o) =>
          o.status == OrderStatus.delivered ||
          o.status == OrderStatus.cancelled)
      .toList();

  /// Create a new order from cart
  Future<Order> createOrder({
    required CartProvider cart,
    required String deliveryAddress,
    double deliveryFee = 0.0,
  }) async {
    final items = cart.items.map((cartItem) {
      return OrderItem(
        product: cartItem.product,
        quantity: cartItem.quantity,
        priceAtPurchase: cartItem.product.currentPrice,
      );
    }).toList();

    final order = Order(
      id: _generateOrderId(),
      items: items,
      totalAmount: cart.totalPrice,
      deliveryFee: deliveryFee,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      deliveryAddress: deliveryAddress,
    );

    _orders.add(order);
    await _saveToStorage();
    notifyListeners();

    return order;
  }

  /// Generate a mock order ID
  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'VGO${timestamp.toString().substring(5)}';
  }

  /// Update order status (for demo purposes)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      final updatedOrder = Order(
        id: oldOrder.id,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        deliveryFee: oldOrder.deliveryFee,
        status: newStatus,
        createdAt: oldOrder.createdAt,
        deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : null,
        deliveryAddress: oldOrder.deliveryAddress,
      );
      _orders[index] = updatedOrder;
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Load orders from persistent storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);

      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        _orders.clear();
        _orders.addAll(decoded.map((item) => Order.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading orders from storage: $e');
    }
  }

  /// Save orders to persistent storage
  Future<void> _saveToStorage() async {
    try {
      // Capture state synchronously
      final key = _storageKey;
      final ordersJson = json.encode(_orders.map((o) => o.toJson()).toList());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, ordersJson);
    } catch (e) {
      debugPrint('Error saving orders to storage: $e');
    }
  }

  /// Clear all order history
  Future<void> clearHistory() async {
    _orders.clear();
    await _saveToStorage();
    notifyListeners();
  }

  /// Add mock orders for demo/testing
  void addMockOrders() {
    // This is just for demonstration purposes
    // In a real app, orders would come from a backend
  }
}
