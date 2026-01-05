import '../../data/repositories/product_repository.dart';

/// Use case for getting all categories
class GetCategories {
  final ProductRepository repository;

  GetCategories(this.repository);

  Future<List<String>> call() async {
    return await repository.getCategories();
  }
}
