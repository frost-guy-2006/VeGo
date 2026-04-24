import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/order_model.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/order_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockFunctionsClient extends Mock implements FunctionsClient {}
class MockFunctionResponse extends Mock implements FunctionResponse {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockFunctionsClient mockFunctionsClient;
  late OrderRepository orderRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockFunctionsClient = MockFunctionsClient();
    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
    
    orderRepository = OrderRepository(client: mockSupabaseClient);
  });

  group('OrderRepository', () {
    test('createOrder invokes edge function and returns Order on success', () async {
      // Arrange
      final mockResponse = MockFunctionResponse();
      when(() => mockResponse.status).thenReturn(200);
      when(() => mockResponse.data).thenReturn({
        'data': {
          'id': 'test-order-123',
          'created_at': DateTime.now().toIso8601String(),
        }
      });

      when(() => mockFunctionsClient.invoke(
        'checkout',
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      final dummyProduct = Product(
        id: 'p1',
        name: 'Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 15,
        harvestTime: '',
        stock: 50,
      );

      final items = [
        OrderItem(product: dummyProduct, quantity: 2, priceAtPurchase: 10),
      ];

      // Act
      final order = await orderRepository.createOrder(
        userId: 'user-123',
        items: items,
        totalAmount: 20.0,
        deliveryAddress: 'Home',
      );

      // Assert
      expect(order.id, 'test-order-123');
      expect(order.totalAmount, 20.0);
      expect(order.items.length, 1);
      
      verify(() => mockFunctionsClient.invoke('checkout', body: any(named: 'body'))).called(1);
    });

    test('createOrder throws exception if status is not 200', () async {
      // Arrange
      final mockResponse = MockFunctionResponse();
      when(() => mockResponse.status).thenReturn(500);
      when(() => mockResponse.data).thenReturn({'error': 'Server Error'});

      when(() => mockFunctionsClient.invoke(
        'checkout',
        body: any(named: 'body'),
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => orderRepository.createOrder(
          userId: 'user-123',
          items: [],
          totalAmount: 0.0,
          deliveryAddress: 'Home',
        ),
        throwsException,
      );
    });
  });
}
