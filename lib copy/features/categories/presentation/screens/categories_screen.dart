import 'package:darazcl/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:darazcl/features/categories/presentation/providers/categories_provider.dart';
import 'package:darazcl/features/products/presentation/widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _TopSearchBar(),
            const SizedBox(height: 4),
            Expanded(
              child: provider.isLoadingCategories && provider.categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null &&
                          provider.categories.isEmpty &&
                          !provider.isLoadingCategories
                      ? Center(child: Text(provider.error!))
                      : Row(
                          children: const [
                            _LeftSidebar(),
                            Expanded(child: _RightContent()),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 38,
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Search for products...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _LeftSidebar extends StatelessWidget {
  const _LeftSidebar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final categories = provider.categories;

    return Container(
      width: 90,
      color: Colors.grey.shade50,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == provider.selectedCategory;
          final icon = _iconForCategory(category);
          final label = _labelForCategory(category);

          return InkWell(
            onTap: () {
              provider.selectCategory(category);
            },
            child: Container(
              height: 88,
              color: selected ? Colors.white : Colors.transparent,
              child: Stack(
                children: [
                  if (selected)
                    Positioned(
                      left: 0,
                      top: 16,
                      bottom: 16,
                      child: Container(
                        width: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            color: selected
                                ? AppColors.primary
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.w500,
                              color: selected
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RightContent extends StatelessWidget {
  const _RightContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();

    return Container(
      color: AppColors.backgroundLight,
      child: RefreshIndicator(
        onRefresh: () => context.read<CategoriesProvider>().refresh(),
        child: provider.isLoadingProducts && provider.products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null && provider.products.isEmpty
                ? Center(child: Text(provider.error!))
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: _PromoBanner(
                            category: provider.selectedCategory ?? '',
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (provider.selectedCategory ?? '')
                                    .toUpperCase()
                                    .replaceAll("'", ''),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                '${provider.products.length} items',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = provider.products[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  context.push('/product/${product.id}');
                                },
                              );
                            },
                            childCount: provider.products.length,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 21 / 9,
            child: Image.network(
              'https://images.pexels.com/photos/325153/pexels-photo-325153.jpeg?auto=compress&cs=tinysrgb&w=600',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_labelForCategory(category)} Sale',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Up to 40% OFF',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForCategory(String category) {
  final key = category.toLowerCase();
  if (key.contains('electronic')) return Icons.devices;
  if (key.contains('jewel')) return Icons.diamond_outlined;
  if (key.contains('men')) return Icons.male;
  if (key.contains('women')) return Icons.female;
  return Icons.category;
}

String _labelForCategory(String category) {
  if (category.isEmpty) return '';
  return category[0].toUpperCase() + category.substring(1);
}

