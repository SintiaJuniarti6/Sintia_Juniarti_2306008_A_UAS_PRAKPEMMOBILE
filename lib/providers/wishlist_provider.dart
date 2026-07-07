import 'package:flutter/material.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  List<WishlistItem> _items = [];

  List<WishlistItem> get items => _items;
  int get totalItemCount => _items.length;

  // Panggil ini sekali di awal (misal di initState HomeScreen) buat load data dari Hive
  void loadWishlist() {
    _items = _wishlistService.getAll();
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _wishlistService.isInWishlist(productId);
  }

  // Toggle status wishlist untuk sebuah produk, lalu refresh list
  Future<bool> toggleWishlist({
    required String productId,
    required String productName,
    String? productImage,
    required double price,
    String? categoryName,
  }) async {
    final item = WishlistItem(
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      categoryName: categoryName,
      addedAt: DateTime.now(),
    );

    final isNowInWishlist = await _wishlistService.toggle(item);
    loadWishlist();
    return isNowInWishlist;
  }

  Future<void> removeFromWishlist(String productId) async {
    await _wishlistService.remove(productId);
    loadWishlist();
  }
}
