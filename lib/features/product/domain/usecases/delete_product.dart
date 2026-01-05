import '../../data/repositories/product_repository.dart';

/// Use case for deleting a product
class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteProduct(id);
  }
}
