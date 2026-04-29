import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/app_error.dart';
import 'package:vego/core/models/product_model.dart';

/// Repository for product-related data operations
class ProductRepository {
  final SupabaseClient _client;

  ProductRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Default page size for pagination
  static const int defaultPageSize = 10;

  /// Fetch all products from database
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw AppError.from(e);
    }
  }

  /// Fetch products with pagination support
  /// [page] - Zero-indexed page number
  /// [pageSize] - Number of items per page
  Future<List<Product>> fetchProductsPaginated({
    int page = 0,
    int pageSize = defaultPageSize,
    String? category,
  }) async {
    try {
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
    } catch (e) {
      throw AppError.from(e);
    }
  }

  /// Check if there are more products to load
  Future<bool> hasMoreProducts({
    int currentCount = 0,
    String? category,
  }) async {
    try {
      var query = _client.from('products').select('id');

      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }

      final countResponse = await query.count(CountOption.exact);
      final totalCount = countResponse.count;
      return currentCount < totalCount;
    } catch (e) {
      throw AppError.from(e);
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      if (category == 'All') {
        return fetchProducts();
      }

      final response = await _client
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw AppError.from(e);
    }
  }

  /// Fetch a single product by ID
  Future<Product?> fetchProductById(String id) async {
    try {
      final response =
          await _client.from('products').select().eq('id', id).maybeSingle();

      if (response == null) return null;
      return Product.fromJson(response);
    } catch (e) {
      throw AppError.from(e);
    }
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    try {
      final safeQuery = query.replaceAll('%', '\\%').replaceAll('_', '\\_');
      final response = await _client
          .from('products')
          .select()
          .ilike('name', '%$safeQuery%')
          .order('name');

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw AppError.from(e);
    }
  }

  /// Fetch flash deals
  Future<List<Product>> fetchFlashDeals() async {
    try {
      final response = await _client.from('products').select().limit(5);
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw AppError.from(e);
    }
  }
}
