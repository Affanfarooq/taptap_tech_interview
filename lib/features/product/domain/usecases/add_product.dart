import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Use case for adding a new product
class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<ProductModel> call(ProductModel product) async {
    return await repository.addProduct(product);
  }
}
