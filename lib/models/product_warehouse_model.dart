class ProductWarehouse {
  final String productId;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final int quantity;

  ProductWarehouse({
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
  });

  factory ProductWarehouse.fromJson(Map<String, dynamic> json) {
    return ProductWarehouse(
      productId: json['Product_ID'],
      productName: json['Product_Name'],
      warehouseId: json['WareHouse_ID'],
      warehouseName: json['Warehouses_Name'],
      quantity: json['Quantity'],
    );
  }
}