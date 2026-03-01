1. **Update `ProductRepository`**
   - Add a `searchProductsByColor(String color)` method to `ProductRepository` that delegates the color filtering to the backend (Supabase) instead of fetching all products. We can do this with `.or()` queries mapping color to keywords (as hinted in memory: 'tomato' for red, etc).

2. **Update `SearchScreen` constructor to accept `ProductRepository`**
   - Change `SearchScreen` constructor to optionally take a `ProductRepository` for dependency injection.
   - Update `_SearchScreenState` to use `widget.productRepository ?? ProductRepository()`. This allows us to inject a mock in tests.

3. **Implement Debounce and Server-Side Filtering in `SearchScreen`**
   - Add a `Timer? _debounce` to `_SearchScreenState`.
   - Update `onChanged` in the `TextField` to use the debounce timer. Wait for 500ms before calling `_performSearch`.
   - Update `_performSearch` to use `_productRepository.searchProductsByColor(color)` when `_activeColorFilter` is present, or `_productRepository.searchProducts(query)` otherwise.
   - Handle the `initialQuery` properly (call immediately without debounce).

4. **Write/Update Benchmark Test**
   - Implement the `MockProductRepository` tracking calls.
   - Write a test in `freshflow/test/search_benchmark_test.dart` that inputs characters rapidly. Verify that `searchProducts` or `searchProductsByColor` is only called once due to the debounce, and that `fetchProducts` is no longer called.

5. **Pre-commit Steps**
   - Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.

6. **Submit PR**
   - Commit the changes and create a PR with performance improvement details.