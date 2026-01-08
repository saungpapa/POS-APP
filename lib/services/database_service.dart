import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        barcode $textType UNIQUE,
        name $textType,
        price $realType,
        stock_quantity $integerType,
        created_at $textType
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        total_amount $realType,
        sale_date $textType
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id $idType,
        sale_id $integerType,
        product_id $integerType,
        quantity $integerType,
        unit_price $realType,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
  }

  // Product CRUD operations
  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert('products', product.toMap());
    return product.copyWith(id: id);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product?> getProduct(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    const orderBy = 'created_at DESC';
    final result = await db.query('products', orderBy: orderBy);
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sale operations
  Future<Sale> createSale(Sale sale, List<SaleItem> items) async {
    final db = await instance.database;
    
    // Start transaction
    return await db.transaction((txn) async {
      // Insert sale
      final saleId = await txn.insert('sales', sale.toMap());
      
      // Insert sale items
      for (var item in items) {
        await txn.insert(
          'sale_items',
          item.copyWith(saleId: saleId).toMap(),
        );
        
        // Update product stock
        final product = await getProduct(item.productId);
        if (product != null) {
          await txn.update(
            'products',
            {'stock_quantity': product.stockQuantity - item.quantity},
            where: 'id = ?',
            whereArgs: [item.productId],
          );
        }
      }
      
      return sale.copyWith(id: saleId);
    });
  }

  Future<List<Sale>> getAllSales() async {
    final db = await instance.database;
    const orderBy = 'sale_date DESC';
    final result = await db.query('sales', orderBy: orderBy);
    return result.map((json) => Sale.fromMap(json)).toList();
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await instance.database;
    final result = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return result.map((json) => SaleItem.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

extension SaleItemCopyWith on SaleItem {
  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? quantity,
    double? unitPrice,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

extension SaleCopyWith on Sale {
  Sale copyWith({
    int? id,
    double? totalAmount,
    DateTime? saleDate,
  }) {
    return Sale(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      saleDate: saleDate ?? this.saleDate,
    );
  }
}
