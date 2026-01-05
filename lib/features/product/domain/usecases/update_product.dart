import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Use case for updating a product
class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<ProductModel> call(ProductModel product) async {
    return await repository.updateProduct(product);
  }
}
