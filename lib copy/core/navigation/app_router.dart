import 'package:darazcl/core/theme/app_theme.dart';
import 'package:darazcl/features/categories/presentation/screens/categories_screen.dart';
import 'package:darazcl/features/home/presentation/screens/home_screen.dart';
import 'package:darazcl/features/products/presentation/screens/product_details_screen.dart';
import 'package:darazcl/features/products/presentation/screens/product_list_screen.dart';
import 'package:darazcl/features/cart/presentation/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _RootShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const MaterialPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              name: 'shop',
              pageBuilder: (context, state) => const MaterialPage(
                child: ProductListScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              name: 'categories',
              pageBuilder: (context, state) => const MaterialPage(
                child: CategoriesScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              name: 'cart',
              pageBuilder: (context, state) => const MaterialPage(
                child: CartScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      name: 'product',
      pageBuilder: (context, state) {
        final idParam = state.pathParameters['id'];
        final id = int.tryParse(idParam ?? '') ?? 0;
        return MaterialPage(
          key: state.pageKey,
          child: ProductDetailsScreen(productId: id),
        );
      },
    ),
  ],
);

class _RootShell extends StatelessWidget {
  const _RootShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 24),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}

