import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Use case for searching products
class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<ProductListResponse> call(
    String query, {
    int skip = 0,
    int limit = 10,
  }) async {
    return await repository.searchProducts(query, skip: skip, limit: limit);
  }
}
