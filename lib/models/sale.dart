class Sale {
  final int? id;
  final double totalAmount;
  final DateTime saleDate;

  Sale({
    this.id,
    required this.totalAmount,
    required this.saleDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'sale_date': saleDate.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      totalAmount: map['total_amount'] as double,
      saleDate: DateTime.parse(map['sale_date'] as String),
    );
  }
}
