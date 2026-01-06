import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/product_model.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import '../widgets/product_form_dialog.dart';

/// Product Details Page
class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductModel? _product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    final state = context.read<ProductCubit>().state;
    if (state is ProductLoaded) {
      _product = state.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => state.products.first,
      );
    }
  }

  void _onEdit() {
    if (_product != null) {
      ProductFormDialog.show(context, product: _product);
    }
  }

  void _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${_product?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ProductCubit>().deleteProductById(widget.productId);
      context.go('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _onEdit,
            tooltip: 'Edit Product',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _onDelete,
            tooltip: 'Delete Product',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingIndicator(
              message: 'Loading product details...',
            );
          } else if (state is ProductLoaded) {
            final product = state.products.firstWhere(
              (p) => p.id == widget.productId,
              orElse: () => state.products.first,
            );
            _product = product;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images
                  _buildImageGallery(product),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.brand,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Stock Status and Category
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Chip(
                              avatar: Icon(
                                product.isInStock
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: product.isInStock
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              label: Text(product.stockStatus),
                              backgroundColor: product.isInStock
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                            ),
                            Chip(
                              avatar: const Icon(
                                Icons.category_outlined,
                                size: 20,
                              ),
                              label: Text(product.category),
                            ),
                            Chip(
                              avatar: const Icon(
                                Icons.inventory_2_outlined,
                                size: 20,
                              ),
                              label: Text('${product.stock} in stock'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 32),

                        // Product Details
                        _buildDetailsCard(context, product),

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _onEdit,
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Product'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _onDelete,
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete Product'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProductError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<ProductCubit>().loadProducts(),
            );
          }

          return const Center(child: Text('Product not found'));
        },
      ),
    );
  }

  Widget _buildImageGallery(ProductModel product) {
    return Container(
      height: 400,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: product.images.isNotEmpty
          ? PageView.builder(
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  product.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, ProductModel product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Product ID', '#${product.id}'),
            _buildDetailRow(context, 'Brand', product.brand),
            _buildDetailRow(context, 'Category', product.category),
            _buildDetailRow(
              context,
              'Price',
              '\$${product.price.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              context,
              'Discount',
              '${product.discountPercentage.toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              context,
              'Rating',
              '${product.rating.toStringAsFixed(1)} / 5.0',
            ),
            _buildDetailRow(context, 'Stock', '${product.stock} units'),
            _buildDetailRow(context, 'Status', product.stockStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
