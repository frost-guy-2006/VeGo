import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

class MockProductRepository extends ProductRepository {
  int fetchCallCount = 0;
  int searchCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCallCount++;
    return [];
  }
}
