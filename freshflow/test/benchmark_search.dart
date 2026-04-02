import 'package:vego/core/models/product_model.dart';

void main() {
  final List<Map<String, dynamic>> allProductsJson = List.generate(
      100000,
      (i) => {
            'id': '$i',
            'name': i % 10 == 0 ? 'Red Tomato $i' : 'Green Apple $i',
            'image_url': 'http://example.com/$i.jpg',
            'current_price': 10.0,
            'market_price': 12.0,
            'harvest_time': 'Today',
            'stock': 100,
          });

  // Client-side filtering approach
  final stopwatch1 = Stopwatch()..start();
  final allProducts =
      allProductsJson.map((json) => Product.fromJson(json)).toList();
  final filtered1 = allProducts.where((p) => p.color == 'Red').toList();
  stopwatch1.stop();
  print('Client-side filtering: ${stopwatch1.elapsedMilliseconds} ms');

  // Server-side filtering approach (simulated, only receiving matching items from network)
  final serverFilteredJson = allProductsJson
      .where((j) => (j['name'] as String).contains('Tomato'))
      .toList();
  final stopwatch2 = Stopwatch()..start();
  final filtered2 =
      serverFilteredJson.map((json) => Product.fromJson(json)).toList();
  stopwatch2.stop();
  print('Server-side filtering: ${stopwatch2.elapsedMilliseconds} ms');
}
