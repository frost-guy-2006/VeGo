import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';

/// Repository for product-related data operations
class ProductRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all products from database
  Future<List<Product>> fetchProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Product.fromJson(json)).toList();
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
}
