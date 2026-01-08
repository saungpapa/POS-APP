import 'package:pos_app/models/sale.dart';

class Receipt {
  final String receiptNumber;
  final String shopName;
  final DateTime dateTime;
  final List<SaleItem> items;
  final double totalAmount;

  Receipt({
    required this.receiptNumber,
    required this.shopName,
    required this.dateTime,
    required this.items,
    required this.totalAmount,
  });

  factory Receipt.fromSale(Sale sale, String shopName) {
    return Receipt(
      receiptNumber: sale.receiptNumber,
      shopName: shopName,
      dateTime: sale.saleDate,
      items: sale.items,
      totalAmount: sale.totalAmount,
    );
  }
}
