import 'package:darazcl/features/products/data/product_repository.dart';
import 'package:darazcl/features/products/domain/models/product.dart';
import 'package:flutter/foundation.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository);

  final ProductRepository _repository;

  final List<String> _tabs = ['All', 'electronics', 'jewelery'];
  String _selectedTab = 'All';

  List<String> get tabs => _tabs;
  String get selectedTab => _selectedTab;

  List<Product> _allProducts = [];
  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;

  List<Product> get products {
    if (_selectedTab == 'All') return _allProducts;
    return _allProducts
        .where((p) => p.category.toLowerCase() == _selectedTab.toLowerCase())
        .toList();
  }

  Future<void> loadInitial() async {
    if (_allProducts.isNotEmpty || _loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      _allProducts = await _repository.fetchAllProducts();
    } catch (e) {
      _error = 'Failed to load products';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectTab(String tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
  }
}

