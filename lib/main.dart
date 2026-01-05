import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/add_product.dart';
import 'features/product/domain/usecases/delete_product.dart';
import 'features/product/domain/usecases/get_categories.dart';
import 'features/product/domain/usecases/get_products.dart';
import 'features/product/domain/usecases/search_products.dart';
import 'features/product/domain/usecases/update_product.dart';
import 'features/product/presentation/blocs/product_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final httpClient = http.Client();
    final remoteDataSource = ProductRemoteDataSourceImpl(client: httpClient);
    final repository = ProductRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    return MultiBlocProvider(
      providers: [
        // Theme Cubit
        BlocProvider(create: (context) => ThemeCubit()),

        // Product Cubit
        BlocProvider(
          create: (context) => ProductCubit(
            getProducts: GetProducts(repository),
            searchProducts: SearchProducts(repository),
            addProduct: AddProduct(repository),
            updateProduct: UpdateProduct(repository),
            deleteProduct: DeleteProduct(repository),
            getCategories: GetCategories(repository),
          )..loadProducts(), // Load products on app start
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Product Dashboard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
