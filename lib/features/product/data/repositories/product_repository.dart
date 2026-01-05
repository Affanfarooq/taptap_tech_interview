import '../models/product_model.dart';

/// Product repository interface
abstract class ProductRepository {
  /// Get all products with pagination
  Future<ProductListResponse> getProducts({int skip = 0, int limit = 10});

  /// Get a single product by ID
  Future<ProductModel> getProductById(int id);

  /// Search products
  Future<ProductListResponse> searchProducts(
    String query, {
    int skip = 0,
    int limit = 10,
  });

  /// Get products by category
  Future<ProductListResponse> getProductsByCategory(
    String category, {
    int skip = 0,
    int limit = 10,
  });

  /// Get all categories
  Future<List<String>> getCategories();

  /// Add a new product
  Future<ProductModel> addProduct(ProductModel product);

  /// Update a product
  Future<ProductModel> updateProduct(ProductModel product);

  /// Delete a product
  Future<void> deleteProduct(int id);
}
