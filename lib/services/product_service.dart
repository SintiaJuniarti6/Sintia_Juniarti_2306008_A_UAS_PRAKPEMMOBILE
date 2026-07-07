import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // AMBIL DAFTAR PRODUK (dengan search, filter, sort, pagination)
  Future<Map<String, dynamic>> getProducts({
    String? search,
    String? categoryId,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/products',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          if (sort != null) 'sort': sort,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data['data'] as List;
      final products = data.map((json) => ProductModel.fromJson(json)).toList();

      // Ambil info pagination dengan aman (jaga-jaga field null/nama beda)
      final pagination = response.data['pagination'] as Map<String, dynamic>?;

      int currentPage = page;
      int totalPages = 1;

      if (pagination != null) {
        currentPage =
            _toInt(pagination['page'] ?? pagination['current_page']) ?? page;
        totalPages =
            _toInt(pagination['totalPages'] ?? pagination['total_pages']) ?? 1;
      }

      final hasMore = currentPage < totalPages;

      return {
        'success': true,
        'products': products,
        'currentPage': currentPage,
        'totalPages': totalPages,
        'hasMore': hasMore,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Gagal mengambil daftar produk',
        'products': <ProductModel>[],
      };
    }
  }

  // Helper: ubah value apapun (int/String/null) jadi int dengan aman
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // AMBIL DETAIL PRODUK
  Future<Map<String, dynamic>> getProductDetail(String id) async {
    try {
      final response = await _apiService.dio.get('/products/$id');
      final product = ProductModel.fromJson(response.data['data']);
      return {'success': true, 'product': product};
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Gagal mengambil detail produk',
      };
    }
  }

  // AMBIL DAFTAR KATEGORI
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _apiService.dio.get('/categories');
      final data = response.data['data'] as List;
      final categories = data
          .map((json) => CategoryModel.fromJson(json))
          .toList();
      return {'success': true, 'categories': categories};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengambil kategori',
        'categories': <CategoryModel>[],
      };
    }
  }
}
