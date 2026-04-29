import 'package:vego/core/models/product_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

/// Represents an item in an order
class OrderItem {
  final Product product;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.priceAtPurchase,
  });

  double get total => priceAtPurchase * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'priceAtPurchase': priceAtPurchase,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'] as int,
        priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
      );
}

/// Represents a complete order
class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String deliveryAddress;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    this.deliveryFee = 0.0,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    required this.deliveryAddress,
    this.cancellationReason,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get grandTotal => totalAmount + deliveryFee;

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'deliveryFee': deliveryFee,
        'status': statusToString(status),
        'createdAt': createdAt.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'deliveryAddress': deliveryAddress,
        'cancellationReason': cancellationReason,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        items:
            (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] is int
            ? OrderStatus.values[json['status'] as int]
            : statusFromString(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt']),
        deliveredAt: json['deliveredAt'] != null
            ? DateTime.parse(json['deliveredAt'])
            : null,
        deliveryAddress: json['deliveryAddress'],
        cancellationReason: json['cancellationReason'] as String?,
      );

  /// Versioned factory for Supabase data.
  /// Tries relational order_items first, falls back to JSONB.
  factory Order.fromSupabase(Map<String, dynamic> json) {
    // Try V2 (relational) — order_items joined with products
    final orderItems = json['order_items'];
    if (orderItems != null && (orderItems as List).isNotEmpty) {
      return Order._fromRelational(json);
    }
    // Fallback to V1 (JSONB)
    return Order._fromJsonb(json);
  }

  /// Parse from relational order_items (V2 — new schema)
  factory Order._fromRelational(Map<String, dynamic> json) {
    final orderItemsList = (json['order_items'] as List).map((itemJson) {
      final productData = itemJson['products'] as Map<String, dynamic>?;
      return OrderItem(
        product: productData != null
            ? Product.fromJson(productData)
            : Product(
                id: itemJson['product_id'] ?? '',
                name: 'Unknown Product',
                imageUrl: '',
                currentPrice: (itemJson['price_at_purchase'] as num).toDouble(),
                marketPrice: (itemJson['price_at_purchase'] as num).toDouble(),
                harvestTime: '',
                stock: 0,
              ),
        quantity: itemJson['quantity'] as int,
        priceAtPurchase: (itemJson['price_at_purchase'] as num).toDouble(),
      );
    }).toList();

    return Order(
      id: json['id'],
      items: orderItemsList,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      status: statusFromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      deliveryAddress: json['delivery_address'] ?? '',
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  /// Parse from JSONB items blob (V1 — legacy schema)
  factory Order._fromJsonb(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    final orderItems = itemsList.map((itemJson) {
      return OrderItem.fromJson(itemJson);
    }).toList();

    return Order(
      id: json['id'],
      items: orderItems,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      status: statusFromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      deliveryAddress: json['delivery_address'] ?? '',
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  /// Convert database status string to OrderStatus enum
  static OrderStatus statusFromString(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Convert OrderStatus enum to database string
  static String statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}
