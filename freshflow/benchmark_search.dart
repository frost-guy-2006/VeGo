import 'package:vego/core/models/product_model.dart';

void main() {
  // Generate a mock dataset of 10,000 items
  final List<Product> mockDataset = List.generate(10000, (index) {
    return Product(
      id: index.toString(),
      name: 'Product $index ${index % 2 == 0 ? "Tomato" : "Spinach"}',
      imageUrl: '',
      currentPrice: 10.0,
      marketPrice: 12.0,
      harvestTime: 'Today',
      stock: 100,
      color: index % 2 == 0 ? 'Red' : 'Green',
    );
  });

  // Client-side filtering baseline
  final stopwatch = Stopwatch()..start();

  final lowerQuery = 'tomato';
  final filtered = mockDataset
      .where((p) => p.name.toLowerCase().contains(lowerQuery))
      .toList();

  stopwatch.stop();
  // ignore: avoid_print
  print(
      'Client-side filtering of 10,000 items took ${stopwatch.elapsedMilliseconds} ms. Found ${filtered.length} items.');
}
