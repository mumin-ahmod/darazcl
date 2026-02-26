import 'package:darazcl/core/theme/app_theme.dart';
import 'package:darazcl/core/navigation/app_router.dart';
import 'package:darazcl/features/categories/presentation/providers/categories_provider.dart';
import 'package:darazcl/features/products/data/product_repository.dart';
import 'package:darazcl/features/products/presentation/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const DarazApp());
}

class DarazApp extends StatelessWidget {
  const DarazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(ProductRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Daraz Clone',
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
