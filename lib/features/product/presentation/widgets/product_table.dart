import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../blocs/product_cubit.dart';

/// Product Table View for Desktop/Tablet
class ProductTable extends StatefulWidget {
  final List<ProductModel> products;
  final Function(int) onProductTap;
  final Function(ProductModel) onEditProduct;
  final Function(int) onDeleteProduct;

  const ProductTable({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onEditProduct,
    required this.onDeleteProduct,
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
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 24,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    showCheckboxColumn: false,
                    dataRowMinHeight: 72,
                    dataRowMaxHeight: 72,
                    border: TableBorder.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withOpacity(0.5),
                      width: 0.5,
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      product.thumbnail,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.outlineVariant,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 20,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.outline,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product.brand ?? 'No Brand',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.outline,
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
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text('\$${product.price.toStringAsFixed(2)}'),
                          ),
                          DataCell(Text(product.stock.toString())),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: product.isInStock
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.stockStatus,
                                style: TextStyle(
                                  color: product.isInStock
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      widget.onEditProduct(product),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () =>
                                      widget.onDeleteProduct(product.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
