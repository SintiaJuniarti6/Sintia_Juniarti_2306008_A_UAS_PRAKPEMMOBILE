import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // CHECKOUT / BUAT PESANAN BARU
  Future<Map<String, dynamic>> createOrder({
    required String address,
    String? notes,
  }) async {
    try {
      final response = await _apiService.dio.post('/orders', data: {
        'shipping_address': address,
        'notes': notes,
      });

      final data = response.data['data'] ?? response.data;
      final order = OrderModel.fromJson(data);

      return {
        'success': true,
        'message': response.data['message'] ?? 'Pesanan berhasil dibuat',
        'order': order,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal membuat pesanan, coba lagi',
      };
    }
  }

  // AMBIL RIWAYAT PESANAN (dengan pagination)
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.dio.get('/orders', queryParameters: {
        'page': page,
        'limit': limit,
      });

      final data = response.data['data'] as List;
      final orders = data.map((json) => OrderModel.fromJson(json)).toList();

      // Info pagination (kalau API mengirim meta/pagination info)
      final meta = response.data['meta'] ?? response.data['pagination'];
      final hasMore = meta != null
          ? (meta['page'] ?? page) < (meta['total_pages'] ?? 1)
          : orders.length == limit; // fallback kalau API tidak kirim meta

      return {
        'success': true,
        'orders': orders,
        'hasMore': hasMore,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengambil riwayat pesanan',
        'orders': <OrderModel>[],
        'hasMore': false,
      };
    }
  }

  // AMBIL DETAIL SATU PESANAN
  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _apiService.dio.get('/orders/$orderId');
      final data = response.data['data'] ?? response.data;
      final order = OrderModel.fromJson(data);

      return {'success': true, 'order': order};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Gagal mengambil detail pesanan',
      };
    }
  }
}