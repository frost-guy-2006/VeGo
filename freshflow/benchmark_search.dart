import 'dart:math';
import 'package:vego/core/models/product_model.dart';

void main() {
  final random = Random();
  final List<String> names = ['Red Tomato', 'Green Spinach', 'Orange Carrot', 'Yellow Banana', 'Blue Berry', 'Apple', 'Broccoli', 'Cucumber', 'Strawberry'];

  // Generate 100,000 mock products
  final mockProducts = List.generate(100000, (index) {
    return Product(
      id: index.toString(),
      name: names[random.nextInt(names.length)] + ' $index',
      imageUrl: '',
      currentPrice: 1.0,
      marketPrice: 2.0,
      harvestTime: 'Today',
      stock: 10,
    );
  });

  // Benchmark client-side filtering
  final stopwatch = Stopwatch()..start();
  final lowerQuery = 'red';

  // Filter by inferred color
  final filteredColor = mockProducts.where((p) => p.color?.toLowerCase() == lowerQuery).toList();

  // Filter by name
  final filteredName = mockProducts.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();

  stopwatch.stop();

  // ignore: avoid_print
  print('Baseline Client-side filtering time for 100,000 items: ${stopwatch.elapsedMilliseconds} ms');
  // ignore: avoid_print
  print('Found ${filteredColor.length} color items, ${filteredName.length} name items');
}
