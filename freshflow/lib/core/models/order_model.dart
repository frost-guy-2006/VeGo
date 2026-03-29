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

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    this.deliveryFee = 0.0,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    required this.deliveryAddress,
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
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'deliveryAddress': deliveryAddress,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        items:
            (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        status: _parseStatus(json['status'] as int),
        createdAt: DateTime.parse(json['createdAt']),
        deliveredAt: json['deliveredAt'] != null
            ? DateTime.parse(json['deliveredAt'])
            : null,
        deliveryAddress: json['deliveryAddress'],
      );

  static OrderStatus _parseStatus(int index) {
    if (index >= 0 && index < OrderStatus.values.length) {
      return OrderStatus.values[index];
    }
    return OrderStatus.pending;
  }
}
