import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

void main() {
  test('Benchmark search performance', () {
    // Generate 10000 mock products json
    final List<Map<String, dynamic>> allProductsJson = List.generate(
        10000,
        (index) => {
              'id': index.toString(),
              'name': index % 2 == 0 ? 'Tomato $index' : 'Apple $index',
              'price': 1.0,
              'category': 'Vegetable',
              'unit': 'kg',
            });

    // Simulate old approach (fetch all + client filter)
    final stopwatchOld = Stopwatch()..start();
    final allProducts =
        allProductsJson.map((item) => Product.fromJson(item)).toList();
    final lowerQuery = 'tomato';
    final filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    stopwatchOld.stop();

    // Simulate new approach (server filter + fetch few)
    final List<Map<String, dynamic>> filteredProductsJson = allProductsJson
        .where(
            (item) => item['name'].toString().toLowerCase().contains('tomato'))
        .toList();

    final stopwatchNew = Stopwatch()..start();
    final serverFiltered =
        filteredProductsJson.map((item) => Product.fromJson(item)).toList();
    stopwatchNew.stop();

    print('Old approach time: ${stopwatchOld.elapsedMicroseconds} us');
    print('New approach time: ${stopwatchNew.elapsedMicroseconds} us');
    print(
        'Improvement: ${(stopwatchOld.elapsedMicroseconds / stopwatchNew.elapsedMicroseconds).toStringAsFixed(2)}x');
  });
}
