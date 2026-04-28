import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/order_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/repositories/order_repository.dart';
import 'dart:convert';

/// Provider for managing order history.
///
/// Uses OrderRepository for Supabase persistence (primary)
/// and SharedPreferences as a local cache (fallback for offline).
class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;
  final List<Order> _orders = [];
  static const String _storageKey = 'order_history';

  List<Order> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;

  OrderProvider({OrderRepository? repository})
      : _repository = repository ?? OrderRepository();

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

  /// Create a new order from cart — writes to Supabase via OrderRepository
  Future<Order> createOrder({
    required CartProvider cart,
    required String deliveryAddress,
    required String userId,
    double deliveryFee = 0.0,
  }) async {
    final items = cart.items.map((cartItem) {
      return OrderItem(
        product: cartItem.product,
        quantity: cartItem.quantity,
        priceAtPurchase: cartItem.product.currentPrice,
      );
    }).toList();

    // Delegate to repository (handles dual-write + audit logging)
    final order = await _repository.createOrder(
      userId: userId,
      items: items,
      totalAmount: cart.totalPrice,
      deliveryAddress: deliveryAddress,
      deliveryFee: deliveryFee,
    );

    _orders.add(order);
    await _saveToLocalCache();
    notifyListeners();

    return order;
  }

  /// Load orders from Supabase for the current user
  Future<void> loadOrdersFromSupabase(String userId) async {
    try {
      final orders = await _repository.fetchUserOrders(userId);
      _orders.clear();
      _orders.addAll(orders);
      await _saveToLocalCache();
      notifyListeners();
    } catch (e) {
      debugPrint('OrderProvider: Error loading from Supabase: $e');
      // Fall back to local cache if Supabase fails
      await loadFromStorage();
    }
  }

  /// Update order status (for demo purposes)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      
      // Update on Supabase via repository
      try {
        await _repository.updateOrderStatus(
          orderId: orderId,
          oldStatus: Order.statusToString(oldOrder.status),
          newStatus: Order.statusToString(newStatus),
        );
      } catch (e) {
        debugPrint('OrderProvider: Error updating status on Supabase: $e');
      }

      // Update local state
      final updatedOrder = Order(
        id: oldOrder.id,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        deliveryFee: oldOrder.deliveryFee,
        status: newStatus,
        createdAt: oldOrder.createdAt,
        deliveredAt: newStatus == OrderStatus.delivered
            ? (oldOrder.deliveredAt ?? DateTime.now())
            : oldOrder.deliveredAt,
        deliveryAddress: oldOrder.deliveryAddress,
      );
      _orders[index] = updatedOrder;
      await _saveToLocalCache();
      notifyListeners();
    }
  }

  /// Load orders from local cache (SharedPreferences)
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

  /// Save orders to local cache (SharedPreferences)
  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = json.encode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString(_storageKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving orders to storage: $e');
    }
  }

  /// Clear all order history
  Future<void> clearHistory() async {
    _orders.clear();
    await _saveToLocalCache();
    notifyListeners();
  }

  /// Add mock orders for demo/testing
  void addMockOrders() {
    // This is just for demonstration purposes
    // In a real app, orders would come from a backend
  }
}

