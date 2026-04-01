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
  final String? category; // product category (Fruits, Vegetables, etc.)

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketPrice,
    required this.harvestTime,
    required this.stock,
    this.color,
    this.category,
  }) : discountPercent = marketPrice > 0
            ? ((marketPrice - currentPrice) / marketPrice * 100).round()
            : 0;

  static const Map<String, List<String>> colorKeywords = {
    'Red': ['red', 'tomato', 'apple', 'strawberry'],
    'Green': ['green', 'spinach', 'broccoli', 'cucumber'],
    'Orange': ['orange', 'carrot', 'banana'],
    'Blue': [], // As per comments
    'Yellow': []
  };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'current_price': currentPrice,
      'market_price': marketPrice,
      'harvest_time': harvestTime,
      'stock': stock,
      'category': category,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final lowerName = name.toLowerCase();
    // Mock Visual Search Tagging logic
    String? inferredColor;

    // Use the static map to infer color
    for (var entry in colorKeywords.entries) {
      if (entry.value.any((keyword) => lowerName.contains(keyword))) {
        inferredColor = entry.key;
        break; // Stop at first match (priority based on map order if needed)
      }
    }

    return Product(
      id: json['id'],
      name: name,
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString().isEmpty
          ? _getDefaultImage(name)
          : (json['image_url'] ?? json['imageUrl']),
      currentPrice:
          (json['current_price'] ?? json['currentPrice'] as num?)?.toDouble() ??
              0.0,
      marketPrice:
          (json['market_price'] ?? json['marketPrice'] as num?)?.toDouble() ??
              0.0,
      harvestTime: json['harvest_time'] ?? json['harvestTime'] ?? '',
      stock: json['stock'] as int? ?? 0,
      color: inferredColor,
      category: json['category'] as String?,
    );
  }

  static String _getDefaultImage(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('tomato')) {
      return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('carrot')) {
      return 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('spinach')) {
      return 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('broccoli')) {
      return 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('apple')) {
      return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('banana')) {
      return 'https://images.unsplash.com/photo-1571771896328-7963057c1e9c?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('orange')) {
      return 'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('potato')) {
      return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('onion')) {
      return 'https://images.unsplash.com/photo-1506801718693-6cbe163dd497?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('cucumber')) {
      return 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('pepper') || name.contains('capsicum')) {
      return 'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('milk')) {
      return 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('bread')) {
      return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80';
    } else if (name.contains('egg')) {
      return 'https://images.unsplash.com/photo-1519448135893-b6ed8e37602e?auto=format&fit=crop&w=300&q=80';
    }
    // Generic fresh produce fallback
    return 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=300&q=80';
  }
}
