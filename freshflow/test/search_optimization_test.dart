import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Repository
class MockProductRepository extends Fake implements ProductRepository {
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    return [
      Product(
        id: '1',
        name: 'Test Product $query',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 20,
        harvestTime: '',
        stock: 10,
      )
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCount++;
    return [
      Product(
        id: '2',
        name: '$color Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 20,
        harvestTime: '',
        stock: 10,
        color: color,
      )
    ];
  }
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets(
      'SearchScreen debounces input and calls correct repository methods',
      (WidgetTester tester) async {
    // Setup Mock
    final mockRepo = MockProductRepository();

    // Pump Widget with Providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // Find TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter "Ap"
    await tester.enterText(textField, 'Ap');
    await tester.pump(); // Start timer
    await tester.pump(const Duration(milliseconds: 100)); // Advance time

    // Enter "Appl"
    await tester.enterText(textField, 'Appl');
    await tester.pump(); // Start timer
    await tester.pump(const Duration(milliseconds: 100));

    // Enter "Apple"
    await tester.enterText(textField, 'Apple');
    await tester.pump(); // Start timer

    // Verify no calls yet (debounce is 500ms)
    expect(mockRepo.searchProductsCount, 0);

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 500));

    // Wait for async search to complete and UI to update
    await tester.pump();

    // Should have called searchProducts once with "Apple"
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.searchProductsByColorCount, 0);
    expect(find.text('Test Product Apple'), findsOneWidget);

    // Clear text
    await tester.enterText(textField, '');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Now test Color Search "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCount, 1);
    // searchProductsCount stays 1
    expect(mockRepo.searchProductsCount, 1);
    expect(find.text('Red Apple'), findsOneWidget);
    expect(find.text('Visual Search Active'), findsOneWidget);
  });
}
