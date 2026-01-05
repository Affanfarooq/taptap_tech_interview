import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';

/// Search and Filter Bar Widget
class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedCategory;
  final bool? showInStockOnly;
  final Function(String) onSearch;
  final Function(String?) onCategoryFilter;
  final Function(bool?) onStockFilter;
  final VoidCallback onClearFilters;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.showInStockOnly,
    required this.onSearch,
    required this.onCategoryFilter,
    required this.onStockFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Clear Filters
          Row(
            children: [
              Text(
                'Products',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (selectedCategory != null || showInStockOnly != null)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
            ),
            onSubmitted: onSearch,
            onChanged: (value) {
              if (value.isEmpty) {
                onSearch('');
              }
            },
          ),
          const SizedBox(height: 12),

          // Filters
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Category Filter
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  final categories = context
                      .read<ProductCubit>()
                      .categoriesList;

                  return DropdownMenu<String>(
                    width: 200,
                    label: const Text('Category'),
                    hintText: 'All Categories',
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(
                        value: '',
                        label: 'All Categories',
                      ),
                      ...categories.map((category) {
                        return DropdownMenuEntry(
                          value: category,
                          label:
                              category.substring(0, 1).toUpperCase() +
                              category.substring(1),
                        );
                      }),
                    ],
                    onSelected: (value) {
                      onCategoryFilter(value?.isEmpty == true ? null : value);
                    },
                  );
                },
              ),

              // Stock Status Filter
              DropdownMenu<bool>(
                width: 180,
                label: const Text('Stock Status'),
                hintText: 'All Products',
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: false, label: 'All Products'),
                  DropdownMenuEntry(value: true, label: 'In Stock Only'),
                ],
                onSelected: (value) {
                  onStockFilter(value == false ? null : value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
