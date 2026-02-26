import 'package:darazcl/core/network/api_client.dart';
import 'package:darazcl/features/products/domain/models/product.dart';

class ProductRepository {
  ProductRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Product>> fetchAllProducts() async {
    final response = await _client.get<List<dynamic>>('/products');
    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await _client.get<List<dynamic>>('/products/categories');
    final list = response.data ?? [];
    return list.map((e) => e.toString()).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response =
        await _client.get<List<dynamic>>('/products/category/$category');
    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<Product> fetchProduct(int id) async {
    final response = await _client.get<Map<String, dynamic>>('/products/$id');
    return Product.fromJson(response.data ?? <String, dynamic>{});
  }
}

