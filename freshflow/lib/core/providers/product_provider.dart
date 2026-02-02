import 'package:flutter/foundation.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

/// Provider for managing product state with filtering and pagination
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  // Product data
  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  // Filtered products (based on selected category)
  List<Product> get filteredProducts {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  // Category filter
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // Pagination state
  int _currentPage = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Initialize provider by loading initial products
  Future<void> initialize() async {
    await loadProducts();
  }

  /// Load initial set of products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.fetchProductsPaginated(
        page: 0,
        pageSize: ProductRepository.defaultPageSize,
        category: _selectedCategory,
      );
      _currentPage = 0;
      _hasMore = _products.length >= ProductRepository.defaultPageSize;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('ProductProvider: Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newProducts = await _repository.fetchProductsPaginated(
        page: nextPage,
        pageSize: ProductRepository.defaultPageSize,
        category: _selectedCategory,
      );

      _products.addAll(newProducts);
      _currentPage = nextPage;
      _hasMore = newProducts.length >= ProductRepository.defaultPageSize;
    } catch (e) {
      debugPrint('ProductProvider: Error loading more products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh products (pull-to-refresh)
  Future<void> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    await loadProducts();
  }

  /// Select a category to filter products
  void selectCategory(String? category) {
    if (_selectedCategory == category) return;

    _selectedCategory = category;
    _currentPage = 0;
    _hasMore = true;
    loadProducts();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    selectCategory(null);
  }

  /// Search products by query
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];

    try {
      return await _repository.searchProducts(query);
    } catch (e) {
      debugPrint('ProductProvider: Error searching products: $e');
      return [];
    }
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String id) async {
    // First check local cache
    final cached = _products.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;

    // Fetch from repository
    try {
      return await _repository.fetchProductById(id);
    } catch (e) {
      debugPrint('ProductProvider: Error fetching product by ID: $e');
      return null;
    }
  }
}
