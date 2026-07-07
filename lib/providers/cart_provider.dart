import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Set berisi ID item yang sedang diproses (buat loading per-item, misal pas +/- ditekan)
  final Set<String> _processingItemIds = {};

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Total jumlah item (buat badge counter di navbar)
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Grand total seluruh keranjang
  double get grandTotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  bool isItemProcessing(String itemId) => _processingItemIds.contains(itemId);

  // AMBIL ISI KERANJANG
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _cartService.getCart();

    if (result['success']) {
      _items = result['items'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // TAMBAH ITEM KE KERANJANG (dipanggil dari Detail Produk)
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    final result = await _cartService.addToCart(productId: productId, quantity: quantity);

    if (result['success']) {
      // Refresh isi keranjang biar badge counter & list ter-update
      await fetchCart();
    }

    return result;
  }

  // UBAH JUMLAH ITEM (tombol + atau -)
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    _processingItemIds.add(cartItemId);
    notifyListeners();

    final result = await _cartService.updateCartItem(
      cartItemId: cartItemId,
      quantity: newQuantity,
    );

    if (result['success']) {
      // Update quantity secara lokal dulu biar responsif (tanpa nunggu fetch ulang)
      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        final oldItem = _items[index];
        _items[index] = CartItemModel(
          id: oldItem.id,
          productId: oldItem.productId,
          productName: oldItem.productName,
          productImage: oldItem.productImage,
          price: oldItem.price,
          quantity: newQuantity,
          stock: oldItem.stock,
        );
      }
    }

    _processingItemIds.remove(cartItemId);
    notifyListeners();
  }

  // HAPUS SATU ITEM
  Future<void> removeItem(String cartItemId) async {
    _processingItemIds.add(cartItemId);
    notifyListeners();

    final result = await _cartService.removeCartItem(cartItemId);

    if (result['success']) {
      _items.removeWhere((item) => item.id == cartItemId);
    }

    _processingItemIds.remove(cartItemId);
    notifyListeners();
  }

  // KOSONGKAN SELURUH KERANJANG
  Future<Map<String, dynamic>> clearCart() async {
    final result = await _cartService.clearCart();

    if (result['success']) {
      _items = [];
      notifyListeners();
    }

    return result;
  }
}