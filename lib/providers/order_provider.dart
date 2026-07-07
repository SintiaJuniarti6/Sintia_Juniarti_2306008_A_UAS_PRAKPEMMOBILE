import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  // STATE UNTUK CHECKOUT
  bool isCheckingOut = false;
  String? checkoutError;

  // STATE UNTUK RIWAYAT PESANAN
  List<OrderModel> orders = [];
  bool isLoadingOrders = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int _currentPage = 1;
  String? ordersError;

  // STATE UNTUK DETAIL PESANAN
  OrderModel? selectedOrder;
  bool isLoadingDetail = false;
  String? detailError;

  // CHECKOUT / BUAT PESANAN
  Future<bool> checkout({required String address, String? notes}) async {
    isCheckingOut = true;
    checkoutError = null;
    notifyListeners();

    final result = await _orderService.createOrder(address: address, notes: notes);

    isCheckingOut = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      checkoutError = result['message'];
      notifyListeners();
      return false;
    }
  }

  // AMBIL HALAMAN PERTAMA RIWAYAT PESANAN (dipanggil saat buka halaman / refresh)
  Future<void> loadOrders() async {
    isLoadingOrders = true;
    ordersError = null;
    _currentPage = 1;
    notifyListeners();

    final result = await _orderService.getOrders(page: _currentPage);

    isLoadingOrders = false;

    if (result['success'] == true) {
      orders = result['orders'];
      hasMore = result['hasMore'];
    } else {
      ordersError = result['message'];
    }
    notifyListeners();
  }

  // LOAD MORE (infinite scroll / pagination)
  Future<void> loadMoreOrders() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _orderService.getOrders(page: nextPage);

    isLoadingMore = false;

    if (result['success'] == true) {
      orders.addAll(result['orders']);
      hasMore = result['hasMore'];
      _currentPage = nextPage;
    }
    notifyListeners();
  }

  // AMBIL DETAIL SATU PESANAN
  Future<void> loadOrderDetail(String orderId) async {
    isLoadingDetail = true;
    detailError = null;
    selectedOrder = null;
    notifyListeners();

    final result = await _orderService.getOrderDetail(orderId);

    isLoadingDetail = false;

    if (result['success'] == true) {
      selectedOrder = result['order'];
    } else {
      detailError = result['message'];
    }
    notifyListeners();
  }

  // RESET ERROR CHECKOUT (misal dipanggil saat buka ulang halaman checkout)
  void clearCheckoutError() {
    checkoutError = null;
    notifyListeners();
  }
}