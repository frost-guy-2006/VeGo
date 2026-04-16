import 'package:flutter/foundation.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  // Generate 10000 mock products
  final List<Product> mockProducts = List.generate(
      10000,
      (index) => Product(
            id: index.toString(),
            name: index % 2 == 0 ? 'Tomato $index' : 'Cucumber $index',
            imageUrl: '',
            currentPrice: 1.0,
            marketPrice: 1.2,
            harvestTime: 'Today',
            stock: 10,
            color: index % 2 == 0 ? 'Red' : 'Green',
          ));

  final stopwatch = Stopwatch()..start();
  // Filter by name (client-side)
  final filtered = mockProducts
      .where((p) => p.name.toLowerCase().contains('tomato'))
      .toList();
  stopwatch.stop();

  // ignore: avoid_print
  print(
      'Client-side filtering 10,000 items took ${stopwatch.elapsedMicroseconds} microseconds');
}
