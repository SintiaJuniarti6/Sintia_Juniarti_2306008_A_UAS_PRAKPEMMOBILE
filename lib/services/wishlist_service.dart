import 'package:hive_flutter/hive_flutter.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  static const String boxName = 'wishlist_box';

  Box<WishlistItem> get _box => Hive.box<WishlistItem>(boxName);

  // Buka box Hive (dipanggil sekali di main.dart sebelum app jalan)
  static Future<void> init() async {
    Hive.registerAdapter(WishlistItemAdapter());
    await Hive.openBox<WishlistItem>(boxName);
  }

  // Ambil semua item wishlist, terbaru duluan
  List<WishlistItem> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return items;
  }

  // Cek apakah produk tertentu sudah ada di wishlist
  bool isInWishlist(String productId) {
    return _box.values.any((item) => item.productId == productId);
  }

  // Tambah produk ke wishlist
  Future<void> add(WishlistItem item) async {
    await _box.put(item.productId, item);
  }

  // Hapus produk dari wishlist
  Future<void> remove(String productId) async {
    await _box.delete(productId);
  }

  // Toggle: kalau sudah ada, hapus. Kalau belum ada, tambah.
  Future<bool> toggle(WishlistItem item) async {
    if (isInWishlist(item.productId)) {
      await remove(item.productId);
      return false; // sekarang TIDAK ada di wishlist
    } else {
      await add(item);
      return true; // sekarang ADA di wishlist
    }
  }
}