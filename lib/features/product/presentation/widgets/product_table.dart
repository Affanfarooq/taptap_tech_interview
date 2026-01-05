import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../blocs/product_cubit.dart';

/// Product Table View for Desktop/Tablet
class ProductTable extends StatefulWidget {
  final List<ProductModel> products;
  final Function(int) onProductTap;

  const ProductTable({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _onSort(int columnIndex, String sortBy) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });

    context.read<ProductCubit>().sortProducts(
      sortBy,
      ascending: _sortAscending,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            showCheckboxColumn: false,
            columns: [
              DataColumn(label: const Text('ID'), numeric: true),
              DataColumn(
                label: const Text('Product'),
                onSort: (columnIndex, ascending) =>
                    _onSort(columnIndex, 'title'),
              ),
              DataColumn(
                label: const Text('Category'),
                onSort: (columnIndex, ascending) =>
                    _onSort(columnIndex, 'category'),
              ),
              DataColumn(
                label: const Text('Price'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _onSort(columnIndex, 'price'),
              ),
              DataColumn(
                label: const Text('Stock'),
                numeric: true,
                onSort: (columnIndex, ascending) =>
                    _onSort(columnIndex, 'stock'),
              ),
              const DataColumn(label: Text('Status')),
              const DataColumn(label: Text('Actions')),
            ],
            rows: widget.products.map((product) {
              return DataRow(
                onSelectChanged: (_) => widget.onProductTap(product.id),
                cells: [
                  DataCell(Text('#${product.id}')),
                  DataCell(
                    Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            product.thumbnail,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.brand,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Chip(
                      label: Text(
                        product.category,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      product.stock.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: product.isInStock
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.stockStatus,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: product.isInStock ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined),
                          iconSize: 20,
                          tooltip: 'View Details',
                          onPressed: () => widget.onProductTap(product.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          iconSize: 20,
                          tooltip: 'Edit',
                          onPressed: () {
                            // TODO: Open edit dialog (Module 8)
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 20,
                          tooltip: 'Delete',
                          onPressed: () {
                            // TODO: Show delete confirmation (Module 8)
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
