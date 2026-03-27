import 'dart:math';

class Product {
  final String id;
  final String name;
  final String? color;
  Product(this.id, this.name, this.color);
}

void main() {
  final random = Random();
  final colors = ['Red', 'Green', 'Orange', 'Yellow', 'Blue', null];
  final products = List.generate(100000, (i) => Product('id_$i', 'Product $i', colors[random.nextInt(colors.length)]));

  final stopwatch = Stopwatch()..start();
  final filteredColor = products.where((p) => p.color == 'Red').toList();
  stopwatch.stop();

  print('Client-side color filtering of 100,000 products took: ${stopwatch.elapsedMilliseconds} ms. Found: ${filteredColor.length}');

  stopwatch.reset();
  stopwatch.start();
  final filteredName = products.where((p) => p.name.toLowerCase().contains('product 500')).toList();
  stopwatch.stop();

  print('Client-side name filtering of 100,000 products took: ${stopwatch.elapsedMilliseconds} ms. Found: ${filteredName.length}');
}
