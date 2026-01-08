import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/models/receipt.dart';
import 'package:pos_app/models/sales_summary.dart';
import 'package:pos_app/models/sale.dart';
import 'package:pos_app/models/product.dart';

void main() {
  group('Receipt Model Tests', () {
    test('Receipt should format date correctly', () {
      final sale = Sale(
        id: 1,
        totalAmount: 1000.0,
        saleDate: DateTime(2024, 1, 15, 14, 30),
      );

      final product = Product(
        id: 1,
        barcode: '123456',
        name: 'Test Product',
        price: 500.0,
        stockQuantity: 10,
        createdAt: DateTime.now(),
      );

      final receiptItem = ReceiptItem(
        product: product,
        quantity: 2,
        unitPrice: 500.0,
      );

      final receipt = Receipt(
        sale: sale,
        items: [receiptItem],
        shopName: 'Test Shop',
        receiptNumber: '1',
      );

      expect(receipt.formattedDate, '15/1/2024');
      expect(receipt.formattedTime, '14:30');
      expect(receipt.shopName, 'Test Shop');
      expect(receipt.receiptNumber, '1');
    });

    test('ReceiptItem should calculate total price correctly', () {
      final product = Product(
        id: 1,
        barcode: '123456',
        name: 'Test Product',
        price: 500.0,
        stockQuantity: 10,
        createdAt: DateTime.now(),
      );

      final receiptItem = ReceiptItem(
        product: product,
        quantity: 3,
        unitPrice: 500.0,
      );

      expect(receiptItem.totalPrice, 1500.0);
    });
  });

  group('SalesSummary Model Tests', () {
    test('SalesSummary should calculate average sale amount correctly', () {
      final summary = SalesSummary(
        totalRevenue: 10000.0,
        totalSalesCount: 5,
        totalItemsSold: 20,
        topProducts: [],
        dailySales: [],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(summary.averageSaleAmount, 2000.0);
    });

    test('SalesSummary should return 0 for average when no sales', () {
      final summary = SalesSummary(
        totalRevenue: 0.0,
        totalSalesCount: 0,
        totalItemsSold: 0,
        topProducts: [],
        dailySales: [],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(summary.averageSaleAmount, 0.0);
    });

    test('TopProduct should store correct data', () {
      final topProduct = TopProduct(
        productId: 1,
        productName: 'Best Seller',
        quantitySold: 100,
        totalRevenue: 50000.0,
      );

      expect(topProduct.productId, 1);
      expect(topProduct.productName, 'Best Seller');
      expect(topProduct.quantitySold, 100);
      expect(topProduct.totalRevenue, 50000.0);
    });

    test('DailySales should format date correctly', () {
      final dailySales = DailySales(
        date: DateTime(2024, 1, 15),
        revenue: 5000.0,
        salesCount: 10,
      );

      expect(dailySales.formattedDate, '15/1');
      expect(dailySales.revenue, 5000.0);
      expect(dailySales.salesCount, 10);
    });
  });
}
