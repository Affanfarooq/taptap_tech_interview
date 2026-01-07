import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taptap_tech_interview/core/utils/responsive_utils.dart';
import 'package:taptap_tech_interview/features/product/presentation/blocs/product_cubit.dart';
import 'package:taptap_tech_interview/features/product/presentation/blocs/product_state.dart';

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
    final isDesktop = ResponsiveUtils.isDesktop(context);

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
          if (selectedCategory != null || showInStockOnly != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),

          if (isDesktop)
            Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                const SizedBox(width: 16),
                _buildCategoryFilter(context, width: 220),
                const SizedBox(width: 16),
                _buildStockFilter(width: 180),
              ],
            )
          else
            Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = 12.0;
                    final itemWidth = (constraints.maxWidth - spacing) / 2;
                    return Row(
                      children: [
                        _buildCategoryFilter(context, width: itemWidth),
                        SizedBox(width: spacing),
                        _buildStockFilter(width: itemWidth),
                      ],
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: searchController,
        textAlignVertical: TextAlignVertical.center,
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
    );
  }

  Widget _buildCategoryFilter(BuildContext context, {required double width}) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final categories = context.read<ProductCubit>().categoriesList;

        return SizedBox(
          width: width,
          height: 56,
          child: DropdownMenu<String>(
            width: width,
            label: const Text('Category'),
            hintText: 'All Categories',
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: '', label: 'All Categories'),
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
          ),
        );
      },
    );
  }

  Widget _buildStockFilter({required double width}) {
    return SizedBox(
      width: width,
      height: 56,
      child: DropdownMenu<bool>(
        width: width,
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
    );
  }
}
