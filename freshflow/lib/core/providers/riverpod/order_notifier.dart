import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/models/order_model.dart';
import 'package:vego/core/repositories/order_repository.dart';
import 'package:vego/core/providers/riverpod/cart_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Order state for Riverpod.
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  int get orderCount => orders.length;

  /// Orders sorted by most recent first
  List<Order> get recentOrders {
    final sorted = List<Order>.from(orders);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Active orders (not delivered or cancelled)
  List<Order> get activeOrders => orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .toList();

  /// Past orders (delivered or cancelled)
  List<Order> get pastOrders => orders
      .where((o) =>
          o.status == OrderStatus.delivered ||
          o.status == OrderStatus.cancelled)
      .toList();

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Order notifier for Riverpod.
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  static const String _storageKey = 'order_history';

  OrderNotifier({OrderRepository? repository})
      : _repository = repository ?? OrderRepository(),
        super(const OrderState());

  /// Create a new order from cart state
  Future<Order> createOrder({
    required CartState cart,
    required String deliveryAddress,
    required String userId,
    double deliveryFee = 0.0,
  }) async {
    // Client-side stock validation
    for (var cartItem in cart.items) {
      if (cartItem.quantity > cartItem.product.stock) {
        throw Exception('Not enough stock for ${cartItem.product.name}. Available: ${cartItem.product.stock}');
      }
    }

    final items = cart.items.map((cartItem) {
      return OrderItem(
        product: cartItem.product,
        quantity: cartItem.quantity,
        priceAtPurchase: cartItem.product.currentPrice,
      );
    }).toList();

    final order = await _repository.createOrder(
      userId: userId,
      items: items,
      totalAmount: cart.totalPrice,
      deliveryAddress: deliveryAddress,
      deliveryFee: deliveryFee,
    );

    state = state.copyWith(orders: [...state.orders, order]);
    await _saveToLocalCache();

    return order;
  }

  /// Load orders from Supabase for the current user
  Future<void> loadOrdersFromSupabase(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _repository.fetchUserOrders(userId);
      state = state.copyWith(orders: orders, isLoading: false);
      await _saveToLocalCache();
    } catch (e) {
      debugPrint('OrderNotifier: Error loading from Supabase: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      await _loadFromLocalCache();
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final orders = [...state.orders];
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];

      try {
        await _repository.updateOrderStatus(
          orderId: orderId,
          oldStatus: Order.statusToString(oldOrder.status),
          newStatus: Order.statusToString(newStatus),
        );
      } catch (e) {
        debugPrint('OrderNotifier: Error updating status on Supabase: $e');
      }

      orders[index] = Order(
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
      state = state.copyWith(orders: orders);
      await _saveToLocalCache();
    }
  }

  /// Load from local cache (SharedPreferences)
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_storageKey);
      if (ordersJson != null) {
        final List<dynamic> decoded = jsonDecode(ordersJson);
        final orders = decoded.map((item) => Order.fromJson(item)).toList();
        state = state.copyWith(orders: orders);
      }
    } catch (e) {
      debugPrint('OrderNotifier: Error loading from cache: $e');
    }
  }

  /// Save to local cache
  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson =
          jsonEncode(state.orders.map((o) => o.toJson()).toList());
      await prefs.setString(_storageKey, ordersJson);
    } catch (e) {
      debugPrint('OrderNotifier: Error saving to cache: $e');
    }
  }

  /// Cancel an order (only pending/confirmed)
  Future<void> cancelOrder(String orderId) async {
    final orders = [...state.orders];
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = orders[index];
    if (order.status != OrderStatus.pending &&
        order.status != OrderStatus.confirmed) {
      throw Exception('Only pending or confirmed orders can be cancelled');
    }

    try {
      await _repository.cancelOrder(
        orderId: orderId,
        currentStatus: Order.statusToString(order.status),
      );
    } catch (e) {
      debugPrint('OrderNotifier: Error cancelling order on Supabase: $e');
    }

    orders[index] = Order(
      id: order.id,
      items: order.items,
      totalAmount: order.totalAmount,
      deliveryFee: order.deliveryFee,
      status: OrderStatus.cancelled,
      createdAt: order.createdAt,
      deliveredAt: order.deliveredAt,
      deliveryAddress: order.deliveryAddress,
    );
    state = state.copyWith(orders: orders);
    await _saveToLocalCache();
  }

  /// Clear all order history
  void clearHistory() {
    state = const OrderState();
    _saveToLocalCache();
  }
}

/// Riverpod provider for order state.
final orderProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});
