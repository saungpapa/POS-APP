import 'sale.dart';
import 'sale_item.dart';
import 'product.dart';

class Receipt {
  final Sale sale;
  final List<ReceiptItem> items;
  final String shopName;
  final String receiptNumber;

  Receipt({
    required this.sale,
    required this.items,
    required this.shopName,
    required this.receiptNumber,
  });

  String get formattedDate {
    final now = sale.saleDate;
    return '${now.day}/${now.month}/${now.year}';
  }

  String get formattedTime {
    final now = sale.saleDate;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ReceiptItem {
  final Product product;
  final int quantity;
  final double unitPrice;

  ReceiptItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  factory ReceiptItem.fromSaleItem(SaleItem saleItem, Product product) {
    return ReceiptItem(
      product: product,
      quantity: saleItem.quantity,
      unitPrice: saleItem.unitPrice,
    );
  }
}
