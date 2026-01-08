import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/cart_provider.dart';
import 'package:pos_app/models/product.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;

    setUp(() {
      cartProvider = CartProvider();
    });

    test('Initial cart should be empty', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.totalAmount, equals(0.0));
    });

    test('Add product should add new item to cart', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);

      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.itemCount, equals(1));
      expect(cartProvider.items[0].product.name, equals('Test Product'));
      expect(cartProvider.items[0].quantity, equals(1));
    });

    test('Add same product twice should increase quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.addProduct(product);

      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.items[0].quantity, equals(2));
    });

    test('Add different products should increase item count', () {
      final product1 = Product(
        id: 1,
        barcode: 'TEST1',
        name: 'Product 1',
        price: 1000.0,
        stockQuantity: 10,
      );
      final product2 = Product(
        id: 2,
        barcode: 'TEST2',
        name: 'Product 2',
        price: 2000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product1);
      cartProvider.addProduct(product2);

      expect(cartProvider.items.length, equals(2));
      expect(cartProvider.itemCount, equals(2));
    });

    test('Total amount should be calculated correctly', () {
      final product1 = Product(
        id: 1,
        barcode: 'TEST1',
        name: 'Product 1',
        price: 1000.0,
        stockQuantity: 10,
      );
      final product2 = Product(
        id: 2,
        barcode: 'TEST2',
        name: 'Product 2',
        price: 1500.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product1);
      cartProvider.addProduct(product1); // quantity = 2
      cartProvider.addProduct(product2);

      // (1000 * 2) + (1500 * 1) = 3500
      expect(cartProvider.totalAmount, equals(3500.0));
    });

    test('Increase quantity should increment item quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.increaseQuantity(0);

      expect(cartProvider.items[0].quantity, equals(2));
    });

    test('Decrease quantity should decrement item quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.increaseQuantity(0);
      cartProvider.increaseQuantity(0); // quantity = 3
      cartProvider.decreaseQuantity(0); // quantity = 2

      expect(cartProvider.items[0].quantity, equals(2));
    });

    test('Decrease quantity should not go below 1', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.decreaseQuantity(0);

      expect(cartProvider.items[0].quantity, equals(1));
    });

    test('Remove item should delete item from cart', () {
      final product1 = Product(
        id: 1,
        barcode: 'TEST1',
        name: 'Product 1',
        price: 1000.0,
        stockQuantity: 10,
      );
      final product2 = Product(
        id: 2,
        barcode: 'TEST2',
        name: 'Product 2',
        price: 2000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product1);
      cartProvider.addProduct(product2);
      cartProvider.removeItem(0);

      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.items[0].product.name, equals('Product 2'));
    });

    test('Clear should empty the cart', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.addProduct(product);
      cartProvider.clear();

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.totalAmount, equals(0.0));
    });

    test('Update quantity should set specific quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.updateQuantity(0, 5);

      expect(cartProvider.items[0].quantity, equals(5));
      expect(cartProvider.totalAmount, equals(5000.0));
    });

    test('Update quantity with invalid value should not change quantity', () {
      final product = Product(
        id: 1,
        barcode: 'TEST123',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
      );

      cartProvider.addProduct(product);
      cartProvider.updateQuantity(0, 0); // Invalid
      cartProvider.updateQuantity(0, -1); // Invalid

      expect(cartProvider.items[0].quantity, equals(1));
    });
  });
}
