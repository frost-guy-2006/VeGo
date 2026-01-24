class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketPrice;
  final String harvestTime;
  final int discountPercent;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketPrice,
    required this.harvestTime,
  }) : discountPercent = ((marketPrice - currentPrice) / marketPrice * 100).round();
}

// Mock Data
final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Organic Tomatoes',
    imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    currentPrice: 18,
    marketPrice: 30,
    harvestTime: '5:00 AM',
  ),
  Product(
    id: '2',
    name: 'Fresh Spinach',
    imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    currentPrice: 12,
    marketPrice: 20,
    harvestTime: '4:30 AM',
  ),
  Product(
    id: '3',
    name: 'Red Onions',
    imageUrl: 'https://images.unsplash.com/photo-1620574387735-3624d75b2dbc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    currentPrice: 25,
    marketPrice: 40,
    harvestTime: 'Yesterday',
  ),
  Product(
    id: '4',
    name: 'Bell Peppers',
    imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdf5ecd2bd?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    currentPrice: 45,
    marketPrice: 60,
    harvestTime: '6:00 AM',
  ),
];
