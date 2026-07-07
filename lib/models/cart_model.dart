class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final int stock;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.stock,
  });

  // Subtotal = harga satuan x quantity (dihitung otomatis, bukan dari API)
  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Data produk kemungkinan nested (relasi ke tabel products)
    final product = json['products'] ?? json['product'];

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: product != null ? (product['name'] ?? '') : (json['product_name'] ?? ''),
      productImage: product != null ? product['image_url'] : json['product_image'],
      price: _parsePrice(product != null ? product['price'] : json['price']),
      quantity: json['quantity'] ?? 1,
      stock: product != null ? (product['stock'] ?? 0) : (json['stock'] ?? 0),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return value.toDouble();
  }
}