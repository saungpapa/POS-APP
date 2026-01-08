import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pos_app/services/database_service.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/models/sale.dart';
import 'package:pos_app/models/sale_item.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseService Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService.instance;
      // Clear database before each test
      final db = await dbService.database;
      await db.delete('products');
      await db.delete('sales');
      await db.delete('sale_items');
    });

    test('Create product should save to database', () async {
      final product = Product(
        barcode: '1234567890',
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 50,
      );

      final savedProduct = await dbService.createProduct(product);

      expect(savedProduct.id, isNotNull);
      expect(savedProduct.barcode, equals('1234567890'));
      expect(savedProduct.name, equals('Test Product'));
      expect(savedProduct.price, equals(1000.0));
      expect(savedProduct.stockQuantity, equals(50));
    });

    test('Get product by barcode should return correct product', () async {
      final product = Product(
        barcode: '9876543210',
        name: 'Product 2',
        price: 2000.0,
        stockQuantity: 30,
      );

      await dbService.createProduct(product);
      final retrieved = await dbService.getProductByBarcode('9876543210');

      expect(retrieved, isNotNull);
      expect(retrieved!.barcode, equals('9876543210'));
      expect(retrieved.name, equals('Product 2'));
    });

    test('Get product by barcode should return null for non-existent barcode', () async {
      final retrieved = await dbService.getProductByBarcode('nonexistent');
      expect(retrieved, isNull);
    });

    test('Get all products should return all saved products', () async {
      final product1 = Product(
        barcode: 'BARCODE1',
        name: 'Product 1',
        price: 1000.0,
        stockQuantity: 10,
      );
      final product2 = Product(
        barcode: 'BARCODE2',
        name: 'Product 2',
        price: 2000.0,
        stockQuantity: 20,
      );

      await dbService.createProduct(product1);
      await dbService.createProduct(product2);

      final products = await dbService.getAllProducts();

      expect(products.length, equals(2));
      expect(products.any((p) => p.barcode == 'BARCODE1'), isTrue);
      expect(products.any((p) => p.barcode == 'BARCODE2'), isTrue);
    });

    test('Update product should modify existing product', () async {
      final product = Product(
        barcode: 'UPDATE_TEST',
        name: 'Original Name',
        price: 1000.0,
        stockQuantity: 10,
      );

      final saved = await dbService.createProduct(product);
      final updated = saved.copyWith(
        name: 'Updated Name',
        price: 1500.0,
      );

      await dbService.updateProduct(updated);
      final retrieved = await dbService.getProduct(saved.id!);

      expect(retrieved!.name, equals('Updated Name'));
      expect(retrieved.price, equals(1500.0));
      expect(retrieved.barcode, equals('UPDATE_TEST'));
    });

    test('Delete product should remove from database', () async {
      final product = Product(
        barcode: 'DELETE_TEST',
        name: 'To Delete',
        price: 1000.0,
        stockQuantity: 10,
      );

      final saved = await dbService.createProduct(product);
      await dbService.deleteProduct(saved.id!);

      final retrieved = await dbService.getProduct(saved.id!);
      expect(retrieved, isNull);
    });

    test('Create sale should save sale and update stock', () async {
      // Create a product first
      final product = Product(
        barcode: 'SALE_TEST',
        name: 'Product for Sale',
        price: 1000.0,
        stockQuantity: 50,
      );
      final savedProduct = await dbService.createProduct(product);

      // Create a sale
      final sale = Sale(
        totalAmount: 5000.0,
        saleDate: DateTime.now(),
      );

      final saleItems = [
        SaleItem(
          saleId: 0,
          productId: savedProduct.id!,
          quantity: 5,
          unitPrice: 1000.0,
        ),
      ];

      final savedSale = await dbService.createSale(sale, saleItems);

      expect(savedSale.id, isNotNull);

      // Check if stock was updated
      final updatedProduct = await dbService.getProduct(savedProduct.id!);
      expect(updatedProduct!.stockQuantity, equals(45)); // 50 - 5

      // Check if sale items were saved
      final items = await dbService.getSaleItems(savedSale.id!);
      expect(items.length, equals(1));
      expect(items[0].quantity, equals(5));
    });

    test('Get all sales should return saved sales', () async {
      final sale1 = Sale(
        totalAmount: 1000.0,
        saleDate: DateTime.now(),
      );
      final sale2 = Sale(
        totalAmount: 2000.0,
        saleDate: DateTime.now(),
      );

      // Create a dummy product for sales
      final product = Product(
        barcode: 'DUMMY',
        name: 'Dummy',
        price: 1000.0,
        stockQuantity: 100,
      );
      final savedProduct = await dbService.createProduct(product);

      await dbService.createSale(sale1, [
        SaleItem(
          saleId: 0,
          productId: savedProduct.id!,
          quantity: 1,
          unitPrice: 1000.0,
        ),
      ]);
      await dbService.createSale(sale2, [
        SaleItem(
          saleId: 0,
          productId: savedProduct.id!,
          quantity: 2,
          unitPrice: 1000.0,
        ),
      ]);

      final sales = await dbService.getAllSales();

      expect(sales.length, equals(2));
    });
  });
}
