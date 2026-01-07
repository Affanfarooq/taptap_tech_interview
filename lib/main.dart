import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:taptap_tech_interview/core/theme/theme_state.dart';
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
import 'features/product/presentation/blocs/auth_cubit.dart';
import 'features/product/presentation/blocs/product_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final http.Client _httpClient;
  late final ProductCubit _productCubit;
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    final remoteDataSource = ProductRemoteDataSourceImpl(client: _httpClient);
    final repository = ProductRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    _themeCubit = ThemeCubit();
    _authCubit = AuthCubit();
    _productCubit =
        ProductCubit(
            getProducts: GetProducts(repository),
            searchProducts: SearchProducts(repository),
            addProduct: AddProduct(repository),
            updateProduct: UpdateProduct(repository),
            deleteProduct: DeleteProduct(repository),
            getCategories: GetCategories(repository),
          )
          ..loadProducts()
          ..loadCategories();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _themeCubit),
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _productCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Product Dashboard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router(_authCubit),
          );
        },
      ),
    );
  }
}
