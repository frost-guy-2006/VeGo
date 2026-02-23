import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';

/// Repository for product-related data operations
class ProductRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Default page size for pagination
  static const int defaultPageSize = 10;

  /// Fetch all products from database
  Future<List<Product>> fetchProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Fetch products with pagination support
  /// [page] - Zero-indexed page number
  /// [pageSize] - Number of items per page
  Future<List<Product>> fetchProductsPaginated({
    int page = 0,
    int pageSize = defaultPageSize,
    String? category,
  }) async {
    final offset = page * pageSize;

    var query = _client.from('products').select();

    // Apply category filter if specified
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Check if there are more products to load
  Future<bool> hasMoreProducts({
    int currentCount = 0,
    String? category,
  }) async {
    var query = _client.from('products').select('id');

    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }

    final response = await query;
    final totalCount = (response as List).length;
    return currentCount < totalCount;
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    if (category == 'All') {
      return fetchProducts();
    }

    final response = await _client
        .from('products')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Fetch a single product by ID
  Future<Product?> fetchProductById(String id) async {
    final response =
        await _client.from('products').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return Product.fromJson(response);
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    final response = await _client
        .from('products')
        .select()
        .ilike('name', '%$query%')
        .order('name');

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Search products by color (inferred from name)
  Future<List<Product>> searchProductsByColor(String color) async {
    final lowerColor = color.toLowerCase();
    String query;

    if (lowerColor == 'red') {
      query =
          'name.ilike.%red%,name.ilike.%tomato%,name.ilike.%apple%,name.ilike.%strawberry%';
    } else if (lowerColor == 'green') {
      query =
          'name.ilike.%green%,name.ilike.%spinach%,name.ilike.%broccoli%,name.ilike.%cucumber%';
    } else if (lowerColor == 'orange') {
      query = 'name.ilike.%orange%,name.ilike.%carrot%,name.ilike.%banana%';
    } else if (lowerColor == 'blue') {
      query = 'name.ilike.%blue%';
    } else {
      // Fallback or empty if color not supported (like Yellow which is broken in client side too)
      // or we can try to find items with that color name
      query = 'name.ilike.%$lowerColor%';
    }

    final response =
        await _client.from('products').select().or(query).order('name');

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }
}
