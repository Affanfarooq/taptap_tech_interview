import 'package:flutter/material.dart';

/// Pagination Controls Widget
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First Page
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
            tooltip: 'First Page',
          ),

          // Previous Page
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0
                ? () => onPageChanged(currentPage - 1)
                : null,
            tooltip: 'Previous Page',
          ),

          const SizedBox(width: 16),

          // Page Info
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(width: 16),

          // Next Page
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
            tooltip: 'Next Page',
          ),

          // Last Page
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(totalPages - 1)
                : null,
            tooltip: 'Last Page',
          ),
        ],
      ),
    );
  }
}
