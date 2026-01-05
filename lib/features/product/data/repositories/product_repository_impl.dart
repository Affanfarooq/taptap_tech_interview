import '../../../../core/utils/exceptions.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';
import 'product_repository.dart';

/// Implementation of ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProductListResponse> getProducts({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      return await remoteDataSource.getProducts(skip: skip, limit: limit);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      return await remoteDataSource.getProductById(id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProductListResponse> searchProducts(
    String query, {
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      return await remoteDataSource.searchProducts(
        query,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProductListResponse> getProductsByCategory(
    String category, {
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      return await remoteDataSource.getProductsByCategory(
        category,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      return await remoteDataSource.addProduct(product);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      return await remoteDataSource.updateProduct(product);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await remoteDataSource.deleteProduct(id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and transform errors
  Exception _handleError(dynamic error) {
    if (error is ApiException || error is NetworkException) {
      return error as Exception;
    }
    return Exception('An unexpected error occurred: $error');
  }
}
