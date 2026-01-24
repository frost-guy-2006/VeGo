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
  }) : discountPercent =
            ((marketPrice - currentPrice) / marketPrice * 100).round();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'currentPrice': currentPrice,
      'marketPrice': marketPrice,
      'harvestTime': harvestTime,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketPrice: (json['market_price'] as num?)?.toDouble() ?? 0.0,
      harvestTime: json['harvest_time'] ?? '',
      stock: json['stock'] as int? ?? 0,
    );
  }
}
