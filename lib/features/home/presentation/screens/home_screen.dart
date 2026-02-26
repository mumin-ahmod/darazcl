import 'dart:async';

import 'package:darazcl/core/theme/app_theme.dart';
import 'package:darazcl/features/products/presentation/widgets/product_card.dart';
import 'package:darazcl/features/categories/presentation/providers/categories_provider.dart';
import 'package:darazcl/features/products/presentation/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _searchBarIsSticky = false;

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<CategoriesProvider>().refresh(),
      context.read<ProductProvider>().refresh(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().loadInitial();
      context.read<ProductProvider>().loadInitial();
    });
  }

  void _onScroll() {
    final topPadding = MediaQuery.of(context).padding.top;
    final bannerHeight = 260 + topPadding;
    final sticky = _scrollController.offset >= bannerHeight - 80;
    if (sticky != _searchBarIsSticky) {
      setState(() => _searchBarIsSticky = sticky);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.watch<CategoriesProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _PromoBannerCarousel(),
                  ),
                  SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _CategoriesRow(
                    provider: categoriesProvider,
                    onCategoryTap: (category) {
                      context.read<CategoriesProvider>().selectCategory(category);
                      context.go('/categories');
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Just For You',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/shop');
                        },
                        child: const Text(
                          'See More',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (productProvider.isLoading &&
                  productProvider.products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (productProvider.error != null &&
                  productProvider.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Failed to load products')),
                )
              else
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
                        final products = productProvider.products;
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            context.push('/product/${product.id}');
                          },
                        );
                      },
                      childCount: productProvider.products.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
          // Floating / sticky search bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color:
                  _searchBarIsSticky ? Colors.white : Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: const _HomeSearchBar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBannerCarousel extends StatefulWidget {
  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  static const _banners = [
    _PromoBannerData(
      imageUrl:
          'https://images.pexels.com/photos/5632324/pexels-photo-5632324.jpeg?auto=compress&cs=tinysrgb&w=600',
      label: 'Flash Sale',
      headline: 'Up to 70% Off',
      description: 'Limited time deals on top brands',
    ),
    _PromoBannerData(
      imageUrl:
          'https://images.pexels.com/photos/5632407/pexels-photo-5632407.jpeg?auto=compress&cs=tinysrgb&w=600',
      label: 'Mega Deals',
      headline: 'Buy 1 Get 1',
      description: 'Exclusive offers on top picks',
    ),
    _PromoBannerData(
      imageUrl:
          'https://images.pexels.com/photos/5632399/pexels-photo-5632399.jpeg?auto=compress&cs=tinysrgb&w=600',
      label: 'New Arrivals',
      headline: 'Fresh Styles Daily',
      description: 'Discover the latest collections',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _banners.isEmpty) return;
      _currentPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = 260 + topPadding;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _banners.length,
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return _PromoBannerWithSearch(
            imageUrl: banner.imageUrl,
            label: banner.label,
            headline: banner.headline,
            description: banner.description,
          );
        },
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(242, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 36,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Search in Daraz',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          const Icon(
            Icons.photo_camera_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Search',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBannerData {
  final String imageUrl;
  final String label;
  final String headline;
  final String description;

  const _PromoBannerData({
    required this.imageUrl,
    required this.label,
    required this.headline,
    required this.description,
  });
}

class _PromoBannerWithSearch extends StatelessWidget {
  final String imageUrl;
  final String label;
  final String headline;
  final String description;

  const _PromoBannerWithSearch({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.headline,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 260 + topPadding,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(180, 0, 0, 0),
                  Colors.transparent,
                  Color.fromARGB(220, 236, 73, 19),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 78),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({
    required this.provider,
    required this.onCategoryTap,
  });

  final CategoriesProvider provider;
  final void Function(String category) onCategoryTap;

  IconData _iconForCategory(String category) {
    final key = category.toLowerCase();
    if (key.contains('electronic')) return Icons.bolt; // Flash-like
    if (key.contains('jewel')) return Icons.diamond_outlined;
    if (key.contains('men')) return Icons.male;
    if (key.contains('women')) return Icons.female;
    return Icons.grid_view;
  }

  Color _backgroundForIndex(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFFFFF3E0);
      case 1:
        return const Color(0xFFE3F2FD);
      case 2:
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF3E5F5);
    }
  }

  Color _foregroundForIndex(int index) {
    switch (index % 4) {
      case 0:
        return AppColors.primary;
      case 1:
        return const Color(0xFF1E88E5);
      case 2:
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF8E24AA);
    }
  }

  String _labelForCategory(String category) {
    if (category.isEmpty) return '';
    return category[0].toUpperCase() + category.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (provider.isLoadingCategories && provider.categories.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (provider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = provider.categories.take(4).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(items.length, (index) {
        final category = items[index];
        final icon = _iconForCategory(category);
        final bg = _backgroundForIndex(index);
        final fg = _foregroundForIndex(index);
        final label = _labelForCategory(category);

        return InkWell(
          onTap: () => onCategoryTap(category),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fg, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

