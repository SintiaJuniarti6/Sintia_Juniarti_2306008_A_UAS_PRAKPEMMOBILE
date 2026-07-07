class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price; // harga satuan saat order dibuat
  final int quantity;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Data produk kemungkinan nested (relasi ke tabel products), sama seperti CartItemModel
    final product = json['products'] ?? json['product'];

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: product != null ? (product['name'] ?? '') : (json['product_name'] ?? ''),
      productImage: product != null ? product['image_url'] : json['product_image'],
      price: _parsePrice(json['price'] ?? (product != null ? product['price'] : null)),
      quantity: json['quantity'] ?? 1,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return value.toDouble();
  }
}

class OrderModel {
  final String id;
  final String status; // pending, processing, shipped, delivered, cancelled
  final double total;
  final String address;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.address,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  // Nomor pesanan = 8 karakter pertama dari UUID (sesuai spek soal)
  String get orderNumber => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['order_items'] ?? json['items'] ?? [];

    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      total: _parsePrice(json['total_amount'] ?? json['total']),
      address: json['shipping_address']?.toString() ?? json['address']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      items: (itemsJson as List).map((e) => OrderItemModel.fromJson(e)).toList(),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is String) return double.tryParse(value) ?? 0;
    return value.toDouble();
  }
}