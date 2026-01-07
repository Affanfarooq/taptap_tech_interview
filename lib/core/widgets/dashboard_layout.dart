import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taptap_tech_interview/core/theme/theme_state.dart';
import '../theme/theme_cubit.dart';
import '../utils/responsive_utils.dart';
import 'sidebar_navigation.dart';

import '../../features/product/presentation/blocs/auth_cubit.dart';

/// Main dashboard layout with sidebar
class DashboardLayout extends StatelessWidget {
  final Widget child;
  final String? location;

  const DashboardLayout({super.key, required this.child, this.location});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    final state = GoRouterState.of(context);
    final path = state.uri.path;

    final isSubPage = path.startsWith('/products/') && path != '/products';
    final hideAppBar = !ResponsiveUtils.isDesktop(context) && isSubPage;

    return Scaffold(
      appBar: hideAppBar
          ? null
          : AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isMobile ? 'Dashboard' : 'Product Dashboard',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return IconButton(
                      icon: Icon(
                        themeState.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      tooltip: themeState.isDarkMode
                          ? 'Light Mode'
                          : 'Dark Mode',
                    );
                  },
                ),
                const VerticalDivider(width: 1, indent: 12, endIndent: 12),
                const SizedBox(width: 8),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    return PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          context.read<AuthCubit>().logout();
                        }
                      },
                      tooltip: 'User Profile',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Text(
                                authState.username
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 12),
                              Text(
                                authState.username ?? 'User',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 20),
                            ],
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, size: 20),
                              const SizedBox(width: 12),
                              Text(authState.username ?? 'Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
      drawer: !ResponsiveUtils.isDesktop(context) && !hideAppBar
          ? const SidebarNavigation()
          : null,
      body: Row(
        children: [
          if (ResponsiveUtils.isDesktop(context)) const SidebarNavigation(),

          Expanded(child: child),
        ],
      ),
    );
  }
}
