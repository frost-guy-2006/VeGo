import 'package:vego/core/models/product_model.dart';
import 'dart:core';

void main() {
  // Generate 10000 mock product JSONs
  List<Map<String, dynamic>> mockDb = List.generate(10000, (i) {
    String name = 'Product $i';
    if (i % 100 == 0) name = 'Red Apple $i';
    return {
      'id': 'id_$i',
      'name': name,
      'image_url': '',
      'current_price': 10.0,
      'market_price': 12.0,
      'harvest_time': 'Today',
      'stock': 100,
      'category': 'Fruits'
    };
  });

  // Client side filtering baseline
  final stopwatch = Stopwatch()..start();
  final allProducts = mockDb.map((item) => Product.fromJson(item)).toList();
  final filtered = allProducts.where((p) => p.name.toLowerCase().contains('red')).toList();
  stopwatch.stop();

  // ignore: avoid_print
  print('Client-side parsing and filtering 10,000 items took: ${stopwatch.elapsedMicroseconds} us. Found ${filtered.length} items.');

  // Simulated server-side filtering
  final serverStopwatch = Stopwatch()..start();
  // Server returns only the 100 matching items
  final serverResponse = mockDb.where((item) => (item['name'] as String).toLowerCase().contains('red')).toList();
  final parsedResponse = serverResponse.map((item) => Product.fromJson(item)).toList();
  serverStopwatch.stop();

  // ignore: avoid_print
  print('Simulated server-side filtering and parsing took: ${serverStopwatch.elapsedMicroseconds} us. Found ${parsedResponse.length} items.');
}
