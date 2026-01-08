class Product {
  final int? id;
  final String barcode;
  final String name;
  final double price;
  final int stockQuantity;
  final DateTime? createdAt;

  Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
      'stock_quantity': stockQuantity,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      stockQuantity: map['stock_quantity'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    double? price,
    int? stockQuantity,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
