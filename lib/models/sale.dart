class Sale {
  final int? id;
  final String receiptNumber;
  final DateTime saleDate;
  final double totalAmount;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.receiptNumber,
    required this.saleDate,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_number': receiptNumber,
      'sale_date': saleDate.toIso8601String(),
      'total_amount': totalAmount,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, {List<SaleItem>? items}) {
    return Sale(
      id: map['id'] as int?,
      receiptNumber: map['receipt_number'] as String,
      saleDate: DateTime.parse(map['sale_date'] as String),
      totalAmount: (map['total_amount'] as num).toDouble(),
      items: items ?? [],
    );
  }
}

class SaleItem {
  final int? id;
  final int? saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }
}
