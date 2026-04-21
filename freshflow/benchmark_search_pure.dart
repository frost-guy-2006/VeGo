import 'dart:core';

class Product {
  final String id;
  final String name;
  final String? color;

  Product({required this.id, required this.name, this.color});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      color: json['color'],
    );
  }
}

void main() {
  final List<Map<String, dynamic>> mockData = List.generate(10000, (i) => {
    'id': 'id_$i',
    'name': i % 2 == 0 ? 'Tomato $i' : 'Apple $i',
    'color': i % 2 == 0 ? 'Red' : null,
  });

  final sw1 = Stopwatch()..start();
  final allProducts = mockData.map((item) => Product.fromJson(item)).toList();
  final lowerQuery = 'tomato';
  final filteredClientSide = allProducts
      .where((p) => p.name.toLowerCase().contains(lowerQuery))
      .toList();
  sw1.stop();

  print('Client-side parsing and filtering 10000 items took: ${sw1.elapsedMilliseconds} ms');
}
