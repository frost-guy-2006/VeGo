import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vego/core/models/order_model.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/order_repository.dart';
import 'package:vego/core/providers/riverpod/order_notifier.dart';
import 'package:vego/core/providers/riverpod/cart_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late OrderNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockOrderRepository();
    notifier = OrderNotifier(repository: mockRepository);
  });

  group('OrderNotifier', () {
    test('createOrder throws if cart item quantity exceeds product stock', () async {
      // Arrange
      final productWithLowStock = Product(
        id: 'p1',
        name: 'Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 15,
        harvestTime: '',
        stock: 1, // Only 1 in stock
      );

      final cartState = CartState(
        items: [
          CartItem(product: productWithLowStock, quantity: 2), // Trying to buy 2
        ],
      );

      // Act & Assert
      expect(
        () => notifier.createOrder(
          cart: cartState,
          deliveryAddress: 'Home',
          userId: 'user1',
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Not enough stock'))),
      );
    });

    test('createOrder succeeds when stock is sufficient', () async {
      // Arrange
      final dummyProduct = Product(
        id: 'p1',
        name: 'Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 15,
        harvestTime: '',
        stock: 10,
      );

      final cartState = CartState(
        items: [
          CartItem(product: dummyProduct, quantity: 2),
        ],
      );

      final dummyOrder = Order(
        id: 'order1',
        items: [OrderItem(product: dummyProduct, quantity: 2, priceAtPurchase: 10)],
        totalAmount: 20,
        deliveryFee: 0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: 'Home',
      );

      when(() => mockRepository.createOrder(
        userId: any(named: 'userId'),
        items: any(named: 'items'),
        totalAmount: any(named: 'totalAmount'),
        deliveryAddress: any(named: 'deliveryAddress'),
        deliveryFee: any(named: 'deliveryFee'),
      )).thenAnswer((_) async => dummyOrder);

      // Act
      final order = await notifier.createOrder(
        cart: cartState,
        deliveryAddress: 'Home',
        userId: 'user1',
      );

      // Assert
      expect(order.id, 'order1');
      expect(notifier.state.orders.length, 1);
      expect(notifier.state.orders.first.id, 'order1');
    });
  });
}
