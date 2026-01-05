import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_cubit.dart';
import '../utils/responsive_utils.dart';
import 'sidebar_navigation.dart';

/// Main dashboard layout with sidebar
class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.inventory_2,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Product Dashboard'),
          ],
        ),
        actions: [
          // Theme toggle
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
                tooltip: state.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isMobile ? const SidebarNavigation() : null,
      body: Row(
        children: [
          // Sidebar for desktop/tablet
          if (!isMobile) const SidebarNavigation(),

          // Main content
          Expanded(child: child),
        ],
      ),
    );
  }
}
