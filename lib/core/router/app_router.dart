import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/product/presentation/pages/dashboard_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/product/presentation/pages/settings_page.dart';
import '../../features/product/presentation/pages/error_page.dart';
import '../widgets/dashboard_layout.dart';
import '../../features/product/presentation/blocs/auth_cubit.dart';
import '../../features/product/presentation/pages/login_page.dart';
import 'go_router_refresh_stream.dart';

/// App router configuration
class AppRouter {
  static GoRouter router(AuthCubit authCubit) => GoRouter(
    initialLocation: '/products',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/products';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return DashboardLayout(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ProductListPage()),
          ),
          GoRoute(
            path: '/products/:id',
            name: 'product-details',
            pageBuilder: (context, state) {
              final idString = state.pathParameters['id'];
              final id = int.tryParse(idString ?? '') ?? 0;
              return NoTransitionPage(child: ProductDetailsPage(productId: id));
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
  );
}
