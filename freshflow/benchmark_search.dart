import 'dart:math';

// Mock Product
class Product {
  final String name;
  final String? color;
  Product(this.name, this.color);
}

void main() {
  final random = Random();
  final colors = ['Red', 'Green', 'Orange', 'Blue', 'Yellow', null];
  final words = ['apple', 'banana', 'tomato', 'spinach', 'carrot', 'broccoli', 'cucumber', 'strawberry', 'potato', 'onion'];

  // Create 100,000 products
  final allProducts = List.generate(100000, (i) {
    final name = '${words[random.nextInt(words.length)]} ${i}';
    final color = colors[random.nextInt(colors.length)];
    return Product(name, color);
  });

  print('Baseline: Client-side filtering');

  final stopwatch = Stopwatch()..start();

  // Simulate client-side filtering by color (Red)
  final filteredColor = allProducts.where((p) => p.color == 'Red').toList();

  final colorTime = stopwatch.elapsedMicroseconds;
  stopwatch.reset();

  // Simulate client-side filtering by text (tomato)
  final filteredText = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();

  final textTime = stopwatch.elapsedMicroseconds;
  stopwatch.stop();

  print('Time to filter 100,000 items by color: ${colorTime / 1000} ms. Found ${filteredColor.length}');
  print('Time to filter 100,000 items by text: ${textTime / 1000} ms. Found ${filteredText.length}');
  print('Note: Server-side filtering avoids this client-side iteration and network payload overhead completely.');
}
