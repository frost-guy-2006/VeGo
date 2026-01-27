import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockProductRepository extends ProductRepository {
  int searchCallCount = 0;
  int colorSearchCallCount = 0;
  String? lastQuery;
  String? lastColor;

  @override
  Future<List<Product>> fetchProducts() async {
    // Should not be called in optimized version
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCallCount++;
    lastQuery = query;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    colorSearchCallCount++;
    lastColor = color;
    return [];
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    // Initialize Supabase to prevent crash in ProductRepository constructor
    // handling the case where Supabase.instance is accessed.
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'dummy',
    );
  });

  testWidgets('SearchScreen uses server-side filtering and debouncing', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    // Inject the mock repository (assuming SearchScreen constructor is updated)
    // Note: This will be a compilation error until SearchScreen is updated.
    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    // Case 1: Text Search with Debounce
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'ap');
    await tester.pump(const Duration(milliseconds: 100)); // less than debounce
    await tester.enterText(textField, 'apple');
    await tester.pump(const Duration(milliseconds: 600)); // wait for debounce

    // Verify searchProducts was called only once (for 'apple') and not for 'ap'
    expect(mockRepo.searchCallCount, 1, reason: 'Should debounce and call search once');
    expect(mockRepo.lastQuery, 'apple');
    expect(mockRepo.colorSearchCallCount, 0);

    // Reset counts
    mockRepo.searchCallCount = 0;
    mockRepo.lastQuery = null;

    // Case 2: Color Search
    // Enter 'Red'
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProductsByColor was called
    expect(mockRepo.colorSearchCallCount, 1, reason: 'Should call color search');
    expect(mockRepo.lastColor, 'Red');
    expect(mockRepo.searchCallCount, 0);
  });
}
