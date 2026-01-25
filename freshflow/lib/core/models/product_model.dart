class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketPrice;
  final String harvestTime;
  final int stock;
  final int discountPercent;

  final String? color; // inferred from name for demo

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketPrice,
    required this.harvestTime,
    required this.stock,
    this.color,
  }) : discountPercent = marketPrice > 0
            ? ((marketPrice - currentPrice) / marketPrice * 100).round()
            : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'current_price': currentPrice,
      'market_price': marketPrice,
      'harvest_time': harvestTime,
      'stock': stock,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    // Mock Visual Search Tagging logic
    String? inferredColor;
    if (name.toLowerCase().contains('red') ||
        name.toLowerCase().contains('tomato') ||
        name.toLowerCase().contains('apple') ||
        name.toLowerCase().contains('strawberry')) {
      inferredColor = 'Red';
    } else if (name.toLowerCase().contains('green') ||
        name.toLowerCase().contains('spinach') ||
        name.toLowerCase().contains('broccoli') ||
        name.toLowerCase().contains('cucumber')) {
      inferredColor = 'Green';
    } else if (name.toLowerCase().contains('orange') ||
        name.toLowerCase().contains('carrot') ||
        name.toLowerCase().contains('banana')) {
      // Banana is yellow/orange-ish in context or we can add Yellow
      inferredColor = 'Orange';
    }

    // For "Blue Packet" demo, let's arbitrarily tag something as Blue if it doesn't match above or if we add specific items later.
    // Let's say "Blue" search finds nothing for now unless we add chips, OR we can map "Cauliflower" to "Blue" just to show the feature working if user searches "Blue".
    // Better yet, let's map 'Berry' or generic items.
    // Actually, let's just leave it natural. If I search "Red" I should see Red items.

    return Product(
      id: json['id'],
      name: name,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      currentPrice:
          (json['current_price'] ?? json['currentPrice'] as num?)?.toDouble() ??
              0.0,
      marketPrice:
          (json['market_price'] ?? json['marketPrice'] as num?)?.toDouble() ??
              0.0,
      harvestTime: json['harvest_time'] ?? json['harvestTime'] ?? '',
      stock: json['stock'] as int? ?? 0,
      color: inferredColor,
    );
  }
}
