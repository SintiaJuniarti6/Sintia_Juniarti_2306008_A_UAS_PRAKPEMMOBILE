import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiService _apiService = ApiService();

  List<dynamic> _extractItemsList(dynamic responseData) {
    final data = responseData['data'] ?? responseData;

    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      if (data['items'] is List) return data['items'];
      if (data['cart_items'] is List) return data['cart_items'];
      if (data['cart'] is List) return data['cart'];
    }

    return [];
  }

  // ===============================
  // GET CART
  // ===============================
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _apiService.dio.get('/cart');

      print("========== CART RESPONSE ==========");
      print(response.data);
      print("===================================");

      final itemsJson = _extractItemsList(response.data);

      print("========== ITEMS ==========");
      print(itemsJson);
      print("===========================");

      final items = itemsJson
          .map<CartItemModel>((e) => CartItemModel.fromJson(e))
          .toList();

      print("========== MODEL ==========");
      print(items.length);
      print("===========================");

      return {
        'success': true,
        'items': items,
      };
    } on DioException catch (e) {
      print("========== CART ERROR ==========");
      print(e.response?.data);
      print("===============================");

      return {
        'success': false,
        'message': e.response?.data['message'] ??
            'Gagal mengambil keranjang',
        'items': <CartItemModel>[],
      };
    } catch (e) {
      print(e);

      return {
        'success': false,
        'message': e.toString(),
        'items': <CartItemModel>[],
      };
    }
  }

  // ===============================
  // ADD CART
  // ===============================
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/cart',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );

      return {
        'success': true,
        'message':
            response.data['message'] ?? 'Berhasil ditambahkan ke keranjang',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ??
                'Gagal menambahkan ke keranjang',
      };
    }
  }

  // ===============================
  // UPDATE CART
  // ===============================
  Future<Map<String, dynamic>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/cart/$cartItemId',
        data: {
          'quantity': quantity,
        },
      );

      return {
        'success': true,
        'message':
            response.data['message'] ??
                'Jumlah berhasil diupdate',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ??
                'Gagal update jumlah',
      };
    }
  }

  // ===============================
  // DELETE ITEM
  // ===============================
  Future<Map<String, dynamic>> removeCartItem(
      String cartItemId) async {
    try {
      final response =
          await _apiService.dio.delete('/cart/$cartItemId');

      return {
        'success': true,
        'message':
            response.data['message'] ??
                'Item berhasil dihapus',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ??
                'Gagal menghapus item',
      };
    }
  }

  // ===============================
  // CLEAR CART
  // ===============================
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response =
          await _apiService.dio.delete('/cart');

      return {
        'success': true,
        'message':
            response.data['message'] ??
                'Keranjang berhasil dikosongkan',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ??
                'Gagal mengosongkan keranjang',
      };
    }
  }
}