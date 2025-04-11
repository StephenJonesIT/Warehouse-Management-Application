import 'package:bai1/models/supplier_models.dart';

class Product {
  final String productId;
  final String productName;
  final int price;
  final int? discount; // Nullable
  final int? plantType; // Nullable
  final String? status; // Nullable
  final String? unit; // Nullable
  final String? urlImage; // Nullable
  final String? description; // Nullable
  final int? categoryId; // Nullable
  final int? supplierId; // Nullable
  final String createAt;
  final String updateAt;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    this.discount,
    this.plantType,
    this.status,
    this.unit,
    this.urlImage,
    this.description,
    this.categoryId,
    this.supplierId,
    required this.createAt,
    required this.updateAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      productName: json['product_name'],
      price: json['price'],
      discount: json['discount'], // No need for conditional assignment here
      plantType: json['plant_type'],
      status: json['status'],
      unit: json['unit'],
      urlImage: json['image_url'],
      description: json['description'],
      categoryId: json['category_id'],
      supplierId: json['supplier_id'],
      createAt: json['create_at'],
      updateAt: json['update_at'],
    );
  }
}