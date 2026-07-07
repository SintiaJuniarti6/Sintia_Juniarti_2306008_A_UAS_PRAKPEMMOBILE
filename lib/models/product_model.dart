class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int stock;
  final String categoryId;
  final String? categoryName;
  final String? imageUrl;
  final bool isActive;
  final double averageRating;
  final int totalReviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.isActive = true,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
      // categories itu nested object hasil join, ambil name-nya kalau ada
      categoryName: json['categories'] != null ? json['categories']['name'] : null,
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      // Dua field ini cuma ada di response detail produk (GET /products/:id)
      // Di daftar produk (GET /products), field ini gak ada -> otomatis default 0
      averageRating: (json['average_rating'] is String)
          ? double.tryParse(json['average_rating']) ?? 0
          : (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}