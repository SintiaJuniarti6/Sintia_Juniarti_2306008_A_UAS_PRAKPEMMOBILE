import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../auth/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchProductDetail(widget.productId);
      provider.fetchProductReviews(widget.productId);
    });
  }

  String _formatRupiah(double price) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(price);
  }

  Future<void> _toggleWishlist(BuildContext context, dynamic product) async {
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    final isNowInWishlist = await wishlistProvider.toggleWishlist(
      productId: product.id,
      productName: product.name,
      productImage: product.imageUrl,
      price: product.price,
      categoryName: product.categoryName,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowInWishlist
              ? 'Ditambahkan ke Wishlist'
              : 'Dihapus dari Wishlist',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showReviewForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    double selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tulis Ulasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Rating'),
                  const SizedBox(height: 8),
                  Center(
                    child: RatingBar.builder(
                      initialRating: 5,
                      minRating: 1,
                      itemCount: 5,
                      itemSize: 36,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) => setSheetState(() => selectedRating = rating),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Komentar (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<ProductProvider>(
                      builder: (context, provider, _) {
                        return ElevatedButton(
                          onPressed: provider.isSubmittingReview
                              ? null
                              : () async {
                                  final result = await provider.submitReview(
                                    productId: widget.productId,
                                    rating: selectedRating.toInt(),
                                    comment: commentController.text.trim(),
                                  );

                                  if (!sheetContext.mounted) return;
                                  Navigator.pop(sheetContext);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message']),
                                      backgroundColor: result['success'] ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          child: provider.isSubmittingReview
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Kirim Ulasan'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    if (productProvider.isLoadingDetail) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = productProvider.selectedProduct;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final isInWishlist = wishlistProvider.isInWishlist(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : null,
            ),
            tooltip: 'Wishlist',
            onPressed: () => _toggleWishlist(context, product),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  _formatRupiah(product.price),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${product.averageRating.toStringAsFixed(1)} (${product.totalReviews} ulasan)',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    if (product.categoryName != null)
                      Chip(
                        label: Text(product.categoryName!, style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${product.stock}',
                  style: TextStyle(
                    fontSize: 13,
                    color: product.stock > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const Divider(height: 32),
                const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Tidak ada deskripsi',
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showReviewForm(context),
                      icon: const Icon(Icons.rate_review_outlined, size: 18),
                      label: const Text('Tulis Ulasan'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (productProvider.isLoadingReviews)
                  const Center(child: CircularProgressIndicator())
                else if (productProvider.reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Belum ada ulasan untuk produk ini', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...productProvider.reviews.map((review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      review.userName ?? 'Pengguna',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < review.rating ? Icons.star : Icons.star_border,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (review.comment != null && review.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(review.comment!, style: const TextStyle(fontSize: 13)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: product.stock > 0
                ? () async {
                    if (!authProvider.isLoggedIn) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      return;
                    }

                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    final result = await cartProvider.addToCart(productId: product.id);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.shopping_cart),
            label: Text(product.stock > 0 ? 'Tambah ke Keranjang' : 'Stok Habis'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ),
    );
  }
}