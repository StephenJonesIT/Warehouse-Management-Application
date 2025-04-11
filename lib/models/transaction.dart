class Transaction {
  final String transactionId;
  final String productId;
  final int warehouseId;
  final int quantity;
  final String transactionType;
  final DateTime transactionDate;
  final String productName;
  final String warehouseName;

  Transaction({
    required this.transactionId,
    required this.productId,
    required this.warehouseId,
    required this.quantity,
    required this.transactionType,
    required this.transactionDate,
    required this.productName,
    required this.warehouseName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      quantity: json['quantity'],
      transactionType: json['transaction_type'],
      transactionDate: DateTime.parse(json['transaction_date']),
      productName: json['Product_Name'],
      warehouseName: json['Warehouses_Name'],
    );
  }
}