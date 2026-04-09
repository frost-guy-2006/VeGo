import 'package:vego/core/models/product_model.dart';

void main() {
  // Generate 100,000 mock JSON items
  final List<Map<String, dynamic>> mockData = List.generate(100000, (index) => {
    'id': index.toString(),
    'name': index % 2 == 0 ? 'Fresh Tomato $index' : 'Green Spinach $index',
    'image_url': '',
    'current_price': 10.0,
    'market_price': 15.0,
    'harvest_time': 'Today',
    'stock': 100,
    'category': 'Vegetables'
  });

  print('Starting baseline benchmark...');

  final stopwatch = Stopwatch()..start();

  // Baseline: Client-side filtering (what _performSearch currently does)
  // 1. Map all items
  final allProducts = mockData.map((item) => Product.fromJson(item)).toList();

  // 2. Filter client-side
  final filtered = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();

  stopwatch.stop();

  print('Baseline took: ${stopwatch.elapsedMilliseconds}ms');
  print('Found ${filtered.length} items.');
}
