class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String? userName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      // Kemungkinan nama user ada di object bersarang (relasi ke profiles/users)
      userName: json['profiles'] != null
          ? json['profiles']['full_name']
          : (json['user_name'] ?? json['full_name']),
      rating: json['rating'] is String
          ? int.tryParse(json['rating']) ?? 0
          : (json['rating'] ?? 0),
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}