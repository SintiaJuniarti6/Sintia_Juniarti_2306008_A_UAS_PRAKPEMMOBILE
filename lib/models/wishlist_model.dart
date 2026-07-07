import 'package:hive/hive.dart';

part 'wishlist_model.g.dart';

@HiveType(typeId: 0)
class WishlistItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String? productImage;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String? categoryName;

  @HiveField(5)
  final DateTime addedAt;

  WishlistItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.categoryName,
    required this.addedAt,
  });
}