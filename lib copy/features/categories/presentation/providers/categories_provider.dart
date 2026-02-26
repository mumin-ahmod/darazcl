import 'package:darazcl/features/products/data/product_repository.dart';
import 'package:darazcl/features/products/domain/models/product.dart';
import 'package:flutter/foundation.dart';

class CategoriesProvider extends ChangeNotifier {
  CategoriesProvider(this._repository);

  final ProductRepository _repository;

  List<String> _categories = [];
  String? _selectedCategory;
  List<Product> _products = [];

  bool _loadingCategories = false;
  bool _loadingProducts = false;
  String? _error;

  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  List<Product> get products => _products;
  bool get isLoadingCategories => _loadingCategories;
  bool get isLoadingProducts => _loadingProducts;
  String? get error => _error;

  Future<void> loadInitial() async {
    if (_categories.isNotEmpty || _loadingCategories) return;
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _loadingCategories = true;
      _error = null;
      notifyListeners();

      _categories = await _repository.fetchCategories();
      if (_categories.isNotEmpty) {
        _selectedCategory ??= _categories.first;
        await _loadProductsFor(_selectedCategory!);
      }
    } catch (e) {
      _error = 'Failed to load categories';
    } finally {
      _loadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String category) async {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    notifyListeners();
    await _loadProductsFor(category);
  }

  Future<void> refresh() async {
    await _loadCategories();
  }

  Future<void> _loadProductsFor(String category) async {
    try {
      _loadingProducts = true;
      _error = null;
      notifyListeners();

      _products = await _repository.fetchProductsByCategory(category);
    } catch (e) {
      _error = 'Failed to load products';
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }
}

