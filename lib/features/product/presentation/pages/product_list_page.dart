import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_table.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/product_form_dialog.dart';

/// Product List Page
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool? _showInStockOnly;

  @override
  void initState() {
    super.initState();
    // Load categories
    context.read<ProductCubit>().loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<ProductCubit>().loadProducts();
    } else {
      context.read<ProductCubit>().searchProductsByQuery(query);
    }
  }

  void _onCategoryFilter(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<ProductCubit>().filterByCategory(category);
  }

  void _onStockFilter(bool? inStockOnly) {
    setState(() {
      _showInStockOnly = inStockOnly;
    });
    context.read<ProductCubit>().filterByStockStatus(inStockOnly);
  }

  void _onClearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _showInStockOnly = null;
    });
    context.read<ProductCubit>().clearFilters();
  }

  void _onProductTap(int productId) {
    context.go('/products/$productId');
  }

  void _onAddProduct() {
    ProductFormDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          SearchFilterBar(
            searchController: _searchController,
            selectedCategory: _selectedCategory,
            showInStockOnly: _showInStockOnly,
            onSearch: _onSearch,
            onCategoryFilter: _onCategoryFilter,
            onStockFilter: _onStockFilter,
            onClearFilters: _onClearFilters,
          ),

          // Product List
          Expanded(
            child: BlocConsumer<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is ProductError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                } else if (state is ProductOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingIndicator(message: 'Loading products...');
                } else if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return EmptyState(
                      title: 'No Products Found',
                      message: state.searchQuery != null
                          ? 'No products match your search criteria'
                          : 'No products available',
                      icon: Icons.inventory_2_outlined,
                      action:
                          state.searchQuery != null ||
                              state.selectedCategory != null
                          ? ElevatedButton.icon(
                              onPressed: _onClearFilters,
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear Filters'),
                            )
                          : null,
                    );
                  }

                  // Show grid for mobile, table for desktop
                  if (isMobile) {
                    return ProductGrid(
                      products: state.products,
                      onProductTap: _onProductTap,
                    );
                  } else {
                    return ProductTable(
                      products: state.products,
                      onProductTap: _onProductTap,
                    );
                  }
                } else if (state is ProductError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () => context.read<ProductCubit>().loadProducts(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
