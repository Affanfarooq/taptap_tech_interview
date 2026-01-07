import '../../../../core/utils/app_logger.dart';
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

  List<ProductModel> _allProducts = [];
  List<String> _categories = [];

  /// Load products with pagination
  Future<void> loadProducts({
    int page = 0,
    int limit = AppConstants.itemsPerPage,
    bool forceReload = false,
  }) async {
    if (!forceReload &&
        state is ProductLoaded &&
        (state as ProductLoaded).currentPage == page) {
      AppLogger.i('⏭️ Products already loaded for page $page, skipping hit');
      return;
    }

    try {
      AppLogger.i('📦 Loading products (page: $page, limit: $limit)');
      emit(const ProductLoading());

      final skip = page * limit;
      final response = await getProducts(skip: skip, limit: limit);

      _allProducts = response.products;
      final totalPages = (response.total / limit).ceil();

      AppLogger.i('✅ Loaded ${response.products.length} products');

      emit(
        ProductLoaded(
          products: response.products,
          total: response.total,
          currentPage: page,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      AppLogger.e('❌ Error loading products: $e');
      emit(ProductError(e.toString()));
    }
  }

  /// Load more products for infinite scroll (no loading indicator)
  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    if (currentState.currentPage >= currentState.totalPages - 1) return;

    try {
      final nextPage = currentState.currentPage + 1;
      AppLogger.i('➕ Loading more products (page: $nextPage)');

      final skip = nextPage * AppConstants.itemsPerPage;
      final response = await getProducts(
        skip: skip,
        limit: AppConstants.itemsPerPage,
      );

      AppLogger.i('✅ Loaded ${response.products.length} more products');

      // Append new products to existing list
      final updatedProducts = [...currentState.products, ...response.products];

      emit(
        currentState.copyWith(products: updatedProducts, currentPage: nextPage),
      );
    } catch (e) {
      AppLogger.e('❌ Error loading more products: $e');
    }
  }

  /// Search products
  Future<void> searchProductsByQuery(
    String query, {
    int page = 0,
    int limit = AppConstants.itemsPerPage,
  }) async {
    try {
      AppLogger.i('🔍 Searching products: "$query"');
      emit(const ProductLoading());

      final skip = page * limit;
      final response = await searchProducts(query, skip: skip, limit: limit);

      final totalPages = (response.total / limit).ceil();

      AppLogger.i('✅ Search found ${response.products.length} products');

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
      AppLogger.e('❌ Error searching products: $e');
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
      AppLogger.i('🔄 Clearing category filter');
      await loadProducts(page: page, limit: limit);
      return;
    }

    try {
      AppLogger.i('📂 Filtering by category: "$category"');
      emit(const ProductLoading());

      final skip = page * limit;
      final response = await getProducts.repository.getProductsByCategory(
        category,
        skip: skip,
        limit: limit,
      );

      final totalPages = (response.total / limit).ceil();

      AppLogger.i(
        '✅ Category "$category" has ${response.products.length} products',
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
      AppLogger.e('❌ Error filtering by category: $e');
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
  Future<void> loadCategories({bool forceReload = false}) async {
    if (!forceReload && _categories.isNotEmpty) {
      AppLogger.i('⏭️ Categories already loaded, skipping hit');
      return;
    }
    try {
      _categories = await getCategories();
      emit(CategoriesLoaded(_categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  /// Add a new product
  Future<void> addNewProduct(ProductModel product) async {
    // Capture current state BEFORE any emissions
    final previousState = state;

    try {
      AppLogger.i('➕ Adding new product: ${product.title}');
      emit(const ProductLoading());

      final addedProduct = await addProduct(product);
      AppLogger.i('✅ Product added to API');

      // Update local state with new product
      if (previousState is ProductLoaded) {
        AppLogger.i('📝 Adding product to local state');
        final updatedProducts = [addedProduct, ...previousState.products];

        // Emit updated state - no success state to avoid list disappearing
        emit(
          previousState.copyWith(
            products: updatedProducts,
            total: previousState.total + 1,
          ),
        );

        AppLogger.i('✅ Product added successfully');
      } else {
        AppLogger.w(
          '⚠️ Previous state was not ProductLoaded, reloading products',
        );
        await loadProducts();
      }
    } catch (e) {
      AppLogger.e('❌ Error adding product: $e');
      emit(ProductError(e.toString()));
    }
  }

  /// Update an existing product
  Future<void> updateExistingProduct(ProductModel product) async {
    // Capture current state BEFORE any emissions
    final previousState = state;

    try {
      AppLogger.i('✏️ Updating product: ${product.title} (ID: ${product.id})');
      emit(const ProductLoading());

      ProductModel updatedProduct;
      try {
        updatedProduct = await updateProduct(product);
        AppLogger.i('✅ API update successful');
      } catch (e) {
        // dummyjson.com returns 404 when category changes
        // Treat as success and use the product we sent
        if (e.toString().contains('404')) {
          AppLogger.w(
            '⚠️ API returned 404 (mock API limitation), using optimistic update',
          );
          updatedProduct = product;
        } else {
          rethrow;
        }
      }

      // Update local state with new product
      if (previousState is ProductLoaded) {
        AppLogger.i('📝 Updating local state with new product data');

        final updatedProducts = previousState.products.map((p) {
          return p.id == updatedProduct.id ? updatedProduct : p;
        }).toList();

        AppLogger.i(
          '✅ Emitting updated product list (${updatedProducts.length} products)',
        );

        // Emit the updated state - no success state to avoid list disappearing
        emit(previousState.copyWith(products: updatedProducts));

        AppLogger.i('✅ Product updated successfully');
      } else {
        AppLogger.w(
          '⚠️ Previous state was not ProductLoaded, reloading products',
        );
        await loadProducts();
      }
    } catch (e) {
      AppLogger.e('❌ Error updating product: $e');
      emit(ProductError(e.toString()));
    }
  }

  /// Delete a product
  Future<void> deleteProductById(int id) async {
    // Capture current state BEFORE any emissions
    final previousState = state;

    try {
      AppLogger.i('🗑️ Deleting product ID: $id');
      emit(const ProductLoading());

      await deleteProduct(id);
      AppLogger.i('✅ Product deleted from API');

      // Update local state by removing product
      if (previousState is ProductLoaded) {
        AppLogger.i('📝 Removing product from local state');
        final updatedProducts = previousState.products
            .where((p) => p.id != id)
            .toList();

        // Emit updated state - no success state to avoid list disappearing
        emit(
          previousState.copyWith(
            products: updatedProducts,
            total: previousState.total - 1,
          ),
        );

        AppLogger.i('✅ Product deleted successfully');
      } else {
        AppLogger.w(
          '⚠️ Previous state was not ProductLoaded, reloading products',
        );
        await loadProducts();
      }
    } catch (e) {
      AppLogger.e('❌ Error deleting product: $e');
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
