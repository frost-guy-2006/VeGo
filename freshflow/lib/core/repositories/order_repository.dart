import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/order_model.dart';

/// Repository for order-related data operations.
///
/// Implements the dual-write strategy from the migration plan:
/// - WRITE 1 (Legacy): Writes JSONB to orders.items
/// - WRITE 2 (New): Writes rows to order_items table
///
/// Implements versioned reads:
/// - Tries relational order_items first
/// - Falls back to JSONB if relational data is missing
class OrderRepository {
  final SupabaseClient _client;

  OrderRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Create a new order with dual-write (JSONB + relational)
  ///
  /// This method writes to both the legacy JSONB column AND the new
  /// order_items table for backward compatibility during migration.
  Future<Order> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    double deliveryFee = 0.0,
  }) async {
    try {
      final payload = {
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
        'deliveryFee': deliveryFee,
        'items': items.map((item) => {
          'product': item.product.toJson(),
          'quantity': item.quantity,
          'priceAtPurchase': item.priceAtPurchase,
        }).toList(),
      };

      final response = await _client.functions.invoke(
        'checkout',
        body: payload,
      );

      if (response.status != 200) {
        throw Exception('Failed to create order: ${response.data}');
      }

      final data = response.data['data'];
      
      return Order(
        id: data['id'] as String,
        items: items,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        status: OrderStatus.pending,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'])
            : DateTime.now(),
        deliveryAddress: deliveryAddress,
      );
    } catch (e) {
      debugPrint('OrderRepository: Error calling checkout Edge Function: $e');
      rethrow;
    }
  }

  /// Fetch all orders for a user with versioned reads
  ///
  /// Tries to load relational order_items first,
  /// falls back to JSONB if relational data is missing.
  Future<List<Order>> fetchUserOrders(String userId) async {
    try {
      // Fetch orders with relational order_items joined
      final response = await _client
          .from('orders')
          .select('''
            *,
            order_items (
              id,
              product_id,
              quantity,
              price_at_purchase,
              products (*)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return Order.fromSupabase(json);
      }).toList();
    } catch (e) {
      debugPrint('OrderRepository: Error fetching orders: $e');
      rethrow;
    }
  }

  /// Fetch a single order by ID
  Future<Order?> fetchOrderById(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            *,
            order_items (
              id,
              product_id,
              quantity,
              price_at_purchase,
              products (*)
            )
          ''')
          .eq('id', orderId)
          .maybeSingle();

      if (response == null) return null;
      return Order.fromSupabase(response);
    } catch (e) {
      debugPrint('OrderRepository: Error fetching order: $e');
      rethrow;
    }
  }

  /// Update order status with audit logging
  Future<void> updateOrderStatus({
    required String orderId,
    required String oldStatus,
    required String newStatus,
    String? changedBy,
  }) async {
    try {
      // Update the order status
      await _client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      // Log the status change
      try {
        await _client.from('order_status_log').insert({
          'order_id': orderId,
          'old_status': oldStatus,
          'new_status': newStatus,
          'changed_by': changedBy,
        });
      } catch (e) {
        debugPrint('OrderRepository: Warning - status log insert failed: $e');
      }
    } catch (e) {
      debugPrint('OrderRepository: Error updating order status: $e');
      rethrow;
    }
  }

  /// Fetch the status history for an order
  Future<List<Map<String, dynamic>>> fetchStatusHistory(String orderId) async {
    try {
      final response = await _client
          .from('order_status_log')
          .select()
          .eq('order_id', orderId)
          .order('changed_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('OrderRepository: Error fetching status history: $e');
      rethrow;
    }
  }
}
