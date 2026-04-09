import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class MockProductRepository implements ProductRepository {
  int fetchAllCount = 0;
  int searchCount = 0;
  int searchByColorCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchAllCount++;
    return List.generate(
      1000,
      (i) => Product(
        id: 'id_$i',
        name: i % 2 == 0 ? 'Red Apple' : 'Green Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: '',
        stock: 10,
      ),
    );
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCount++;
    return [
      Product(
        id: 'id_search',
        name: 'Searched Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: '',
        stock: 10,
      )
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchByColorCount++;
    return [
      Product(
        id: 'id_color',
        name: 'Color Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: '',
        stock: 10,
      )
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// HttpOverrides to prevent network image errors during tests
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('Search benchmark - types multiple characters',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    // We can't actually pass mockRepo yet because the constructor doesn't accept it in the baseline code.
    // So we'll just test that we can pump the widget for now, but to actually benchmark we need to intercept
    // the network requests or modify the code.
    // Let's modify the file for benchmark testing using the bash session before this test runs.
  });
}
