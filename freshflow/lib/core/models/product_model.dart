class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketPrice;
  final String harvestTime;
  final int stock;
  final int discountPercent;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketPrice,
    required this.harvestTime,
    required this.stock,
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
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      currentPrice:
          (json['current_price'] ?? json['currentPrice'] as num?)?.toDouble() ??
              0.0,
      marketPrice:
          (json['market_price'] ?? json['marketPrice'] as num?)?.toDouble() ??
              0.0,
      harvestTime: json['harvest_time'] ?? json['harvestTime'] ?? '',
      stock: json['stock'] as int? ?? 0,
    );
  }
}
