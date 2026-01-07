import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taptap_tech_interview/features/product/presentation/widgets/pagination_controls.dart';
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
    // No need to manually call load here anymore as ProductCubit
    // handles initial load and smart caching.
    // This prevents redundant API hits on theme changes or navigation.
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
    context.push('/products/$productId');
  }

  void _onAddProduct() {
    ProductFormDialog.show(context);
  }

  void _onEditProduct(dynamic product) {
    ProductFormDialog.show(context, product: product);
  }

  void _onDeleteProduct(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ProductCubit>().deleteProductById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Consistent Header (Title + Add Button only for Desktop)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Products',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ResponsiveUtils.isDesktop(context))
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _onAddProduct,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Product'),
                    ),
                  ),
              ],
            ),
          ),

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

                  return Column(
                    children: [
                      // Show table for desktop, grid for mobile/tablet
                      Expanded(
                        child: ResponsiveUtils.isDesktop(context)
                            ? ProductTable(
                                products: state.products,
                                onProductTap: (id) =>
                                    context.go('/products/$id'),
                                onEditProduct: _onEditProduct,
                                onDeleteProduct: _onDeleteProduct,
                              )
                            : ProductGrid(
                                products: state.products,
                                onProductTap: _onProductTap,
                              ),
                      ),

                      // Pagination Controls - Only show on desktop
                      if (state.totalPages > 1 &&
                          ResponsiveUtils.isDesktop(context))
                        PaginationControls(
                          currentPage: state.currentPage,
                          totalPages: state.totalPages,
                          onPageChanged: (page) {
                            context.read<ProductCubit>().loadProducts(
                              page: page,
                            );
                          },
                        ),
                    ],
                  );
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
      // Show FAB only on mobile/tablet (full width)
      floatingActionButton: !ResponsiveUtils.isDesktop(context)
          ? SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FloatingActionButton.extended(
                  onPressed: _onAddProduct,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
