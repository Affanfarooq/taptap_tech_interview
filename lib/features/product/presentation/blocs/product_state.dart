import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

/// Base state for Product Cubit
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Loading state
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Products loaded successfully
class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final int total;
  final int currentPage;
  final int totalPages;
  final String? searchQuery;
  final String? selectedCategory;
  final bool? showInStockOnly;

  const ProductLoaded({
    required this.products,
    required this.total,
    this.currentPage = 0,
    this.totalPages = 1,
    this.searchQuery,
    this.selectedCategory,
    this.showInStockOnly,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    int? total,
    int? currentPage,
    int? totalPages,
    String? searchQuery,
    String? selectedCategory,
    bool? showInStockOnly,
    bool clearSearchQuery = false,
    bool clearCategory = false,
    bool clearStockFilter = false,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      showInStockOnly: clearStockFilter
          ? null
          : (showInStockOnly ?? this.showInStockOnly),
    );
  }

  @override
  List<Object?> get props => [
    products,
    total,
    currentPage,
    totalPages,
    searchQuery,
    selectedCategory,
    showInStockOnly,
  ];
}

/// Error state
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Product operation success (for add/update/delete)
class ProductOperationSuccess extends ProductState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Categories loaded
class CategoriesLoaded extends ProductState {
  final List<String> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}
