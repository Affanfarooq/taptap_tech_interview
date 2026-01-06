import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/product_model.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/update_product.dart';
import 'product_state.dart';

/// Cubit for managing product state
class ProductCubit extends Cubit<ProductState> {
  final GetProducts getProducts;
  final SearchProducts searchProducts;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;
  final GetCategories getCategories;

  ProductCubit({
    required this.getProducts,
    required this.searchProducts,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.getCategories,
  }) : super(const ProductInitial());

  // Cache for products to avoid unnecessary API calls
  List<ProductModel> _allProducts = [];
  List<String> _categories = [];

  /// Load products with pagination
  Future<void> loadProducts({
    int page = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    try {
      developer.log(
        '📦 Loading products (page: $page, limit: $limit)',
        name: 'ProductCubit',
      );
      emit(const ProductLoading());

      final skip = page * limit;
      final response = await getProducts(skip: skip, limit: limit);

      _allProducts = response.products;
      final totalPages = (response.total / limit).ceil();

      developer.log(
        '✅ Loaded ${response.products.length} products',
        name: 'ProductCubit',
      );

      emit(
        ProductLoaded(
          products: response.products,
          total: response.total,
          currentPage: page,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      developer.log('❌ Error loading products: $e', name: 'ProductCubit');
      emit(ProductError(e.toString()));
    }
  }

  /// Search products
  Future<void> searchProductsByQuery(
    String query, {
    int page = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    try {
      developer.log('🔍 Searching products: "$query"', name: 'ProductCubit');
      emit(const ProductLoading());

      final skip = page * limit;
      final response = await searchProducts(query, skip: skip, limit: limit);

      final totalPages = (response.total / limit).ceil();

      developer.log(
        '✅ Search found ${response.products.length} products',
        name: 'ProductCubit',
      );

      emit(
        ProductLoaded(
          products: response.products,
          total: response.total,
          currentPage: page,
          totalPages: totalPages,
          searchQuery: query,
        ),
      );
    } catch (e) {
      developer.log('❌ Error searching products: $e', name: 'ProductCubit');
      emit(ProductError(e.toString()));
    }
  }

  /// Filter products by category
  Future<void> filterByCategory(
    String? category, {
    int page = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    if (category == null || category.isEmpty) {
      developer.log('🔄 Clearing category filter', name: 'ProductCubit');
      await loadProducts(page: page, limit: limit);
      return;
    }

    try {
      developer.log(
        '📂 Filtering by category: "$category"',
        name: 'ProductCubit',
      );
      emit(const ProductLoading());

      // Use repository's getProductsByCategory method
      final skip = page * limit;
      final response = await getProducts.repository.getProductsByCategory(
        category,
        skip: skip,
        limit: limit,
      );

      final totalPages = (response.total / limit).ceil();

      developer.log(
        '✅ Category "$category" has ${response.products.length} products',
        name: 'ProductCubit',
      );

      emit(
        ProductLoaded(
          products: response.products,
          total: response.total,
          currentPage: page,
          totalPages: totalPages,
          selectedCategory: category,
        ),
      );
    } catch (e) {
      developer.log('❌ Error filtering by category: $e', name: 'ProductCubit');
      emit(ProductError(e.toString()));
    }
  }

  /// Filter products by stock status
  void filterByStockStatus(bool? inStockOnly) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    try {
      emit(const ProductLoading());

      List<ProductModel> filteredProducts;

      if (inStockOnly == true) {
        filteredProducts = _allProducts.where((p) => p.isInStock).toList();
      } else {
        filteredProducts = _allProducts;
      }

      emit(
        currentState.copyWith(
          products: filteredProducts,
          total: filteredProducts.length,
          showInStockOnly: inStockOnly,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await getCategories();
      emit(CategoriesLoaded(_categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Add a new product
  Future<void> addNewProduct(ProductModel product) async {
    try {
      emit(const ProductLoading());

      await addProduct(product);

      emit(const ProductOperationSuccess('Product added successfully'));

      // Reload products
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Update an existing product
  Future<void> updateExistingProduct(ProductModel product) async {
    try {
      emit(const ProductLoading());

      await updateProduct(product);

      emit(const ProductOperationSuccess('Product updated successfully'));

      // Reload products
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Delete a product
  Future<void> deleteProductById(int id) async {
    try {
      emit(const ProductLoading());

      await deleteProduct(id);

      emit(const ProductOperationSuccess('Product deleted successfully'));

      // Reload products
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Clear filters and reload
  Future<void> clearFilters() async {
    await loadProducts();
  }

  /// Sort products
  void sortProducts(String sortBy, {bool ascending = true}) {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    final sortedProducts = List<ProductModel>.from(currentState.products);

    switch (sortBy) {
      case 'title':
        sortedProducts.sort(
          (a, b) => ascending
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title),
        );
        break;
      case 'price':
        sortedProducts.sort(
          (a, b) => ascending
              ? a.price.compareTo(b.price)
              : b.price.compareTo(a.price),
        );
        break;
      case 'stock':
        sortedProducts.sort(
          (a, b) => ascending
              ? a.stock.compareTo(b.stock)
              : b.stock.compareTo(a.stock),
        );
        break;
      case 'category':
        sortedProducts.sort(
          (a, b) => ascending
              ? a.category.compareTo(b.category)
              : b.category.compareTo(a.category),
        );
        break;
    }

    emit(currentState.copyWith(products: sortedProducts));
  }

  /// Get categories list
  List<String> get categoriesList => _categories;
}
