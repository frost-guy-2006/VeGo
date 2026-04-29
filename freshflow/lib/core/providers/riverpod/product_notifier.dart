import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

/// Product state for Riverpod.
class ProductState {
  final List<Product> products;
  final String? selectedCategory;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const ProductState({
    this.products = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  /// Filtered products based on selected category
  List<Product> get filteredProducts {
    if (selectedCategory == null || selectedCategory == 'All') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory).toList();
  }

  ProductState copyWith({
    List<Product>? products,
    String? selectedCategory,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    bool clearCategory = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Product notifier for Riverpod.
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;

  ProductNotifier({ProductRepository? repository})
      : _repository = repository ?? ProductRepository(),
        super(const ProductState()) {
    loadProducts();
  }

  /// Load initial set of products
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _repository.fetchProductsPaginated(
        page: 0,
        pageSize: ProductRepository.defaultPageSize,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        products: products,
        currentPage: 0,
        hasMore: products.length >= ProductRepository.defaultPageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('ProductNotifier: Error loading products: $e');
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final newProducts = await _repository.fetchProductsPaginated(
        page: nextPage,
        pageSize: ProductRepository.defaultPageSize,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        hasMore: newProducts.length >= ProductRepository.defaultPageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('ProductNotifier: Error loading more products: $e');
    }
  }

  /// Refresh products (pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(currentPage: 0, hasMore: true);
    await loadProducts();
  }

  /// Select a category to filter products
  void selectCategory(String? category) {
    if (state.selectedCategory == category) return;

    state = state.copyWith(
      selectedCategory: category,
      currentPage: 0,
      hasMore: true,
      clearCategory: category == null,
    );
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
      debugPrint('ProductNotifier: Error searching products: $e');
      return [];
    }
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String id) async {
    // First check local cache
    final cached = state.products.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;

    try {
      return await _repository.fetchProductById(id);
    } catch (e) {
      debugPrint('ProductNotifier: Error fetching product by ID: $e');
      return null;
    }
  }

  /// Fetch flash deals
  Future<List<Product>> fetchFlashDeals() async {
    try {
      return await _repository.fetchFlashDeals();
    } catch (e) {
      debugPrint('ProductNotifier: Error fetching flash deals: $e');
      return [];
    }
  }
}

/// Riverpod provider for product state.
final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});
