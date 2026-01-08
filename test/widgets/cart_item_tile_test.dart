import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/models/cart_item.dart';
import 'package:pos_app/widgets/cart_item_tile.dart';

void main() {
  group('CartItemTile Widget Tests', () {
    late CartItem testCartItem;

    setUp(() {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
        createdAt: DateTime.now(),
      );
      testCartItem = CartItem(product: product, quantity: 2);
    });

    testWidgets('CartItemTile displays cart item information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: testCartItem,
              onIncrease: () {},
              onDecrease: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('1,000 ကျပ်'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('2,000 ကျပ်'), findsOneWidget);
    });

    testWidgets('CartItemTile increase button triggers callback', (WidgetTester tester) async {
      bool increased = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: testCartItem,
              onIncrease: () => increased = true,
              onDecrease: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      expect(increased, isTrue);
    });

    testWidgets('CartItemTile decrease button triggers callback', (WidgetTester tester) async {
      bool decreased = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: testCartItem,
              onIncrease: () {},
              onDecrease: () => decreased = true,
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pump();

      expect(decreased, isTrue);
    });

    testWidgets('CartItemTile remove button triggers callback', (WidgetTester tester) async {
      bool removed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemTile(
              item: testCartItem,
              onIncrease: () {},
              onDecrease: () {},
              onRemove: () => removed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(removed, isTrue);
    });
  });
}
