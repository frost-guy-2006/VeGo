import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/order_model.dart';

void main() {
  group('Order Model Tests', () {
    test('Order.fromJson handles valid status index', () {
      final json = {
        'id': '1',
        'items': [],
        'totalAmount': 100.0,
        'deliveryFee': 10.0,
        'status': 1, // confirmed
        'createdAt': DateTime.now().toIso8601String(),
        'deliveryAddress': '123 Main St',
      };
      final order = Order.fromJson(json);
      expect(order.status, OrderStatus.confirmed);
    });

    test('Order.fromJson handles invalid status index (too high) by defaulting to pending', () {
      final json = {
        'id': '1',
        'items': [],
        'totalAmount': 100.0,
        'deliveryFee': 10.0,
        'status': 99, // Invalid
        'createdAt': DateTime.now().toIso8601String(),
        'deliveryAddress': '123 Main St',
      };
      final order = Order.fromJson(json);
      expect(order.status, OrderStatus.pending);
    });

    test('Order.fromJson handles invalid status index (negative) by defaulting to pending', () {
      final json = {
        'id': '1',
        'items': [],
        'totalAmount': 100.0,
        'deliveryFee': 10.0,
        'status': -1, // Invalid
        'createdAt': DateTime.now().toIso8601String(),
        'deliveryAddress': '123 Main St',
      };
      final order = Order.fromJson(json);
      expect(order.status, OrderStatus.pending);
    });

    test('Order.fromJson handles null status by defaulting to pending', () {
      final json = {
        'id': '1',
        'items': [],
        'totalAmount': 100.0,
        'deliveryFee': 10.0,
        'status': null, // Invalid
        'createdAt': DateTime.now().toIso8601String(),
        'deliveryAddress': '123 Main St',
      };
      final order = Order.fromJson(json);
      expect(order.status, OrderStatus.pending);
    });
  });
}
