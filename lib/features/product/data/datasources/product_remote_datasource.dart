import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/exceptions.dart';
import '../models/product_model.dart';

/// Remote data source for product API
abstract class ProductRemoteDataSource {
  Future<ProductListResponse> getProducts({int skip = 0, int limit = 10});
  Future<ProductListResponse> searchProducts(
    String query, {
    int skip = 0,
    int limit = 10,
  });
  Future<ProductListResponse> getProductsByCategory(
    String category, {
    int skip = 0,
    int limit = 10,
  });
  Future<List<String>> getCategories();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  void _logRequest(String method, String url, {Map<String, dynamic>? body}) {
    developer.log('🌐 API REQUEST', name: 'ProductAPI', error: '$method $url');
    if (body != null) {
      developer.log(
        '📤 Request Body: ${json.encode(body)}',
        name: 'ProductAPI',
      );
    }
  }

  void _logResponse(int statusCode, String body, {String? endpoint}) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    developer.log(
      '$emoji API RESPONSE',
      name: 'ProductAPI',
      error:
          'Status: $statusCode${endpoint != null ? ' | Endpoint: $endpoint' : ''}',
    );
    developer.log(
      '📥 Response: ${body.length > 500 ? '${body.substring(0, 500)}...' : body}',
      name: 'ProductAPI',
    );
  }

  void _logError(String operation, dynamic error) {
    developer.log(
      '🔴 ERROR in $operation',
      name: 'ProductAPI',
      error: error.toString(),
    );
  }

  @override
  Future<ProductListResponse> getProducts({
    int skip = 0,
    int limit = 10,
  }) async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.productsEndpoint}?limit=$limit&skip=$skip';

    try {
      _logRequest('GET', url);

      final response = await client.get(Uri.parse(url));

      _logResponse(response.statusCode, response.body, endpoint: 'getProducts');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        developer.log(
          '✨ Loaded ${jsonData['products']?.length ?? 0} products',
          name: 'ProductAPI',
        );
        return ProductListResponse.fromJson(jsonData);
      } else {
        throw ApiException('Failed to load products', response.statusCode);
      }
    } catch (e) {
      _logError('getProducts', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductListResponse> searchProducts(
    String query, {
    int skip = 0,
    int limit = 10,
  }) async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/search?q=$query&limit=$limit&skip=$skip';

    try {
      _logRequest('GET', url);

      final response = await client.get(Uri.parse(url));

      _logResponse(
        response.statusCode,
        response.body,
        endpoint: 'searchProducts',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        developer.log(
          '🔍 Search "$query" found ${jsonData['products']?.length ?? 0} products',
          name: 'ProductAPI',
        );
        return ProductListResponse.fromJson(jsonData);
      } else {
        throw ApiException('Failed to search products', response.statusCode);
      }
    } catch (e) {
      _logError('searchProducts', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductListResponse> getProductsByCategory(
    String category, {
    int skip = 0,
    int limit = 10,
  }) async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/category/$category?limit=$limit&skip=$skip';

    try {
      _logRequest('GET', url);

      final response = await client.get(Uri.parse(url));

      _logResponse(
        response.statusCode,
        response.body,
        endpoint: 'getProductsByCategory',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        developer.log(
          '📂 Category "$category" has ${jsonData['products']?.length ?? 0} products',
          name: 'ProductAPI',
        );
        return ProductListResponse.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to load products for category: $category',
          response.statusCode,
        );
      }
    } catch (e) {
      _logError('getProductsByCategory', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/category-list';

    try {
      _logRequest('GET', url);

      final response = await client.get(Uri.parse(url));

      _logResponse(
        response.statusCode,
        response.body,
        endpoint: 'getCategories',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // dummyjson.com returns categories as slug format (e.g., "beauty", "fragrances")
        final categories = jsonData.map((e) => e.toString()).toList();

        developer.log(
          '📋 Loaded ${categories.length} categories: ${categories.take(5).join(", ")}${categories.length > 5 ? '...' : ''}',
          name: 'ProductAPI',
        );

        return categories;
      } else {
        throw ApiException('Failed to load categories', response.statusCode);
      }
    } catch (e) {
      _logError('getCategories', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final url = '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/add';

    try {
      final body = product.toJson();
      _logRequest('POST', url, body: body);

      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      _logResponse(response.statusCode, response.body, endpoint: 'addProduct');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        developer.log(
          '➕ Product added: ${jsonData['title']}',
          name: 'ProductAPI',
        );
        return ProductModel.fromJson(jsonData);
      } else {
        throw ApiException('Failed to add product', response.statusCode);
      }
    } catch (e) {
      _logError('addProduct', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/${product.id}';

    try {
      final body = product.toJson();
      _logRequest('PUT', url, body: body);

      final response = await client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      _logResponse(
        response.statusCode,
        response.body,
        endpoint: 'updateProduct',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        developer.log(
          '✏️ Product updated: ${jsonData['title']}',
          name: 'ProductAPI',
        );
        return ProductModel.fromJson(jsonData);
      } else {
        throw ApiException('Failed to update product', response.statusCode);
      }
    } catch (e) {
      _logError('updateProduct', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    final url = '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/$id';

    try {
      _logRequest('DELETE', url);

      final response = await client.delete(Uri.parse(url));

      _logResponse(
        response.statusCode,
        response.body,
        endpoint: 'deleteProduct',
      );

      if (response.statusCode == 200) {
        developer.log('🗑️ Product deleted: ID $id', name: 'ProductAPI');
      } else {
        throw ApiException('Failed to delete product', response.statusCode);
      }
    } catch (e) {
      _logError('deleteProduct', e);
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to connect to server: $e');
    }
  }
}
