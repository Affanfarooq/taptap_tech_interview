import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Use case for getting products with pagination
class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<ProductListResponse> call({int skip = 0, int limit = 10}) async {
    return await repository.getProducts(skip: skip, limit: limit);
  }
}
