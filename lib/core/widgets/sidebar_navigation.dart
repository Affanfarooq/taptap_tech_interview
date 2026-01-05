import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_utils.dart';

/// Sidebar navigation widget
class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final currentRoute = GoRouterState.of(context).uri.path;

    final navigationItems = [
      _NavigationItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
      ),
      _NavigationItem(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: 'Products',
        route: '/products',
      ),
      _NavigationItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: 'Settings',
        route: '/settings',
      ),
    ];

    if (isMobile) {
      return Drawer(
        child: _buildNavigationContent(
          context,
          navigationItems,
          currentRoute,
          isMobile: true,
        ),
      );
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: _buildNavigationContent(
        context,
        navigationItems,
        currentRoute,
        isMobile: false,
      ),
    );
  }

  Widget _buildNavigationContent(
    BuildContext context,
    List<_NavigationItem> items,
    String currentRoute, {
    required bool isMobile,
  }) {
    return Column(
      children: [
        if (isMobile) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Product Dashboard',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
        ] else ...[
          const SizedBox(height: 24),
        ],

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: items.map((item) {
              final isSelected = currentRoute.startsWith(item.route);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(isSelected ? item.selectedIcon : item.icon),
                  title: Text(item.label),
                  selected: isSelected,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    context.go(item.route);
                    if (isMobile) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
