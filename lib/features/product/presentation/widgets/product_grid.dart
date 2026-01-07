import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/product_model.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';

/// Product Grid View for Mobile with Infinite Scroll
class ProductGrid extends StatefulWidget {
  final List<ProductModel> products;
  final Function(int) onProductTap;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // User scrolled to 90% of the list, load more seamlessly
      final cubit = context.read<ProductCubit>();
      final state = cubit.state;

      if (state is ProductLoaded && state.currentPage < state.totalPages - 1) {
        // Use loadMoreProducts for seamless experience (no loading indicator)
        cubit.loadMoreProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get dynamic column count based on screen width
    final columns = ResponsiveUtils.getGridColumns(context);

    // Adjust aspect ratio based on columns to prevent overflow
    // Side-by-side layout on mobile needs less vertical space
    final aspectRatio = columns == 2 ? 0.85 : (columns == 3 ? 0.85 : 0.9);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns, // Dynamic columns
        childAspectRatio: aspectRatio, // Dynamic aspect ratio
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return _ProductCard(
          product: product,
          onTap: () => widget.onProductTap(product.id),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    );
                  },
                ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Price & Stock Status in a Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        // Stock Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            border: Border.all(
                              color: product.isInStock
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.stockStatus,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: product.isInStock
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
