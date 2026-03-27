import 'package:vego/core/models/product_model.dart';

void main() {
  final List<Product> mockProducts = List.generate(
    100000,
    (index) => Product(
      id: index.toString(),
      name: index % 2 == 0 ? 'Fresh Tomato $index' : 'Green Apple $index',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 12,
      harvestTime: 'Today',
      stock: 100,
    ),
  );

  final stopwatch = Stopwatch()..start();
  final query = 'tomato';
  final lowerQuery = query.toLowerCase();

  // Simulate client-side filtering
  final filtered = mockProducts
      .where((p) => p.name.toLowerCase().contains(lowerQuery))
      .toList();

  stopwatch.stop();
  print(
      'Client-side filtering 100,000 items took: ${stopwatch.elapsedMilliseconds} ms. Found: ${filtered.length}');
}
