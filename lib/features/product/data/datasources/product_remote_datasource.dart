import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/exceptions.dart';
import '../models/product_model.dart';

/// Remote data source for products using dummyjson.com API
abstract class ProductRemoteDataSource {
  /// Get all products with pagination
  Future<ProductListResponse> getProducts({
    int skip = 0,
    int limit = AppConstants.itemsPerPage,
  });

  /// Get a single product by ID
  Future<ProductModel> getProductById(int id);

  /// Search products
  Future<ProductListResponse> searchProducts(
    String query, {
    int skip = 0,
    int limit = AppConstants.itemsPerPage,
  });

  /// Get products by category
  Future<ProductListResponse> getProductsByCategory(
    String category, {
    int skip = 0,
    int limit = AppConstants.itemsPerPage,
  });

  /// Get all categories
  Future<List<String>> getCategories();

  /// Add a new product (mock - dummyjson doesn't persist)
  Future<ProductModel> addProduct(ProductModel product);

  /// Update a product (mock - dummyjson doesn't persist)
  Future<ProductModel> updateProduct(ProductModel product);

  /// Delete a product (mock - dummyjson doesn't persist)
  Future<void> deleteProduct(int id);
}

/// Implementation of ProductRemoteDataSource
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<ProductListResponse> getProducts({
    int skip = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}?skip=$skip&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductListResponse.fromJson(jsonData);
      } else {
        throw ApiException('Failed to load products', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/$id',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw ApiException('Failed to load product', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductListResponse> searchProducts(
    String query, {
    int skip = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/search?q=$query&skip=$skip&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductListResponse.fromJson(jsonData);
      } else {
        throw ApiException('Failed to search products', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductListResponse> getProductsByCategory(
    String category, {
    int skip = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/category/$category?skip=$skip&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductListResponse.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to load products by category',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await client.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/categories',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => e.toString()).toList();
      } else {
        throw ApiException('Failed to load categories', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final response = await client.post(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/add',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw ApiException('Failed to add product', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await client.put(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/${product.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw ApiException('Failed to update product', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      final response = await client.delete(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/$id',
        ),
      );

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete product', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }
}
