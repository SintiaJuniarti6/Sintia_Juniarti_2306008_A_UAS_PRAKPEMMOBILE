import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/review_model.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  // AMBIL DAFTAR ULASAN UNTUK SATU PRODUK
  Future<Map<String, dynamic>> getProductReviews(String productId) async {
    try {
      final response = await _apiService.dio.get('/reviews/product/$productId');
      final data = response.data['data'] as List;
      final reviews = data.map((json) => ReviewModel.fromJson(json)).toList();
      return {'success': true, 'reviews': reviews};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengambil ulasan',
        'reviews': <ReviewModel>[],
      };
    }
  }

  // TAMBAH ULASAN BARU (butuh login)
  Future<Map<String, dynamic>> createReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/reviews/product/$productId',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return {
        'success': true,
        'message': response.data['message'] ?? 'Ulasan berhasil ditambahkan',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal menambahkan ulasan',
      };
    }
  }
}