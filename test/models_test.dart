import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/models/cart_item.dart';

void main() {
  group('Product Model Tests', () {
    test('Product toMap should convert product to map', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
        createdAt: DateTime(2024, 1, 1),
      );

      final map = product.toMap();

      expect(map['id'], equals(1));
      expect(map['barcode'], equals('TEST123'));
      expect(map['name'], equals('Test Product'));
      expect(map['price'], equals(1000.0));
      expect(map['stock_quantity'], equals(50));
      expect(map['created_at'], isNotNull);
    });

    test('Product fromMap should create product from map', () {
      final map = {
        'id': 1,
        'barcode': 'TEST123',
        'name': 'Test Product',
        'price': 1000.0,
        'stock_quantity': 50,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final product = Product.fromMap(map);

      expect(product.id, equals(1));
      expect(product.barcode, equals('TEST123'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(1000.0));
      expect(product.stockQuantity, equals(50));
      expect(product.createdAt, isNotNull);
    });

    test('Product copyWith should create new instance with updated values', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
      );

      final updated = product.copyWith(
        name: 'Updated Product',
        price: 1500.0,
      );

      expect(updated.id, equals(1));
      expect(updated.barcode, equals('TEST123'));
      expect(updated.name, equals('Updated Product'));
      expect(updated.price, equals(1500.0));
      expect(updated.stockQuantity, equals(50));
    });
  });

  group('CartItem Model Tests', () {
    test('CartItem totalPrice should calculate correctly', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
      );

      final cartItem = CartItem(product: product, quantity: 3);

      expect(cartItem.totalPrice, equals(3000.0));
    });

    test('CartItem increaseQuantity should increment quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
      );

      final cartItem = CartItem(product: product, quantity: 1);
      cartItem.increaseQuantity();

      expect(cartItem.quantity, equals(2));
    });

    test('CartItem decreaseQuantity should decrement quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
      );

      final cartItem = CartItem(product: product, quantity: 3);
      cartItem.decreaseQuantity();

      expect(cartItem.quantity, equals(2));
    });

    test('CartItem decreaseQuantity should not go below 1', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
      );

      final cartItem = CartItem(product: product, quantity: 1);
      cartItem.decreaseQuantity();

      expect(cartItem.quantity, equals(1));
    });
  });
}
