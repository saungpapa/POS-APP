import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/widgets/product_card.dart';

void main() {
  group('ProductCard Widget Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
        createdAt: DateTime.now(),
      );
    });

    testWidgets('ProductCard displays product information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: testProduct),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Barcode: TEST123'), findsOneWidget);
      expect(find.text('1,000 ကျပ်'), findsOneWidget);
      expect(find.text('လက်ကျန်: 50'), findsOneWidget);
    });

    testWidgets('ProductCard shows low stock warning for stock < 10', (WidgetTester tester) async {
      final lowStockProduct = testProduct.copyWith(stockQuantity: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: lowStockProduct),
          ),
        ),
      );

      expect(find.text('လက်ကျန်: 5'), findsOneWidget);
    });

    testWidgets('ProductCard onTap callback works', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('ProductCard shows popup menu with edit and delete when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });
}
