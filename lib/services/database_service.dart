import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/models/sale.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_number TEXT UNIQUE NOT NULL,
        sale_date TEXT NOT NULL,
        total_amount REAL NOT NULL
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'key': 'shop_name', 'value': 'ကျွန်တော့်ဆိုင်'});
  }

  Future<void> init() async {
    await database;
  }

  // Product CRUD operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sale operations
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    
    // Insert sale
    final saleId = await db.insert('sales', sale.toMap());
    
    // Insert sale items
    for (var item in sale.items) {
      await db.insert('sale_items', item.toMap()..['sale_id'] = saleId);
      
      // Update product stock
      await db.rawUpdate(
        'UPDATE products SET stock = stock - ? WHERE id = ?',
        [item.quantity, item.productId],
      );
    }
    
    return saleId;
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    
    final saleMaps = await db.query(
      'sales',
      where: 'sale_date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'sale_date DESC',
    );

    final sales = <Sale>[];
    for (var saleMap in saleMaps) {
      final saleId = saleMap['id'] as int;
      
      // Get sale items
      final itemMaps = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );
      
      final items = itemMaps.map((m) => SaleItem.fromMap(m)).toList();
      sales.add(Sale.fromMap(saleMap, items: items));
    }

    return sales;
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await database;
    
    final saleMaps = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (saleMaps.isEmpty) return null;

    final saleMap = saleMaps.first;
    final saleId = saleMap['id'] as int;
    
    // Get sale items
    final itemMaps = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    
    final items = itemMaps.map((m) => SaleItem.fromMap(m)).toList();
    return Sale.fromMap(saleMap, items: items);
  }

  // Settings operations
  Future<String> getSetting(String key, {String defaultValue = ''}) async {
    final db = await database;
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return defaultValue;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Sales statistics
  Future<Map<String, dynamic>> getSalesStats(DateTime start, DateTime end) async {
    final db = await database;
    
    // Total sales and count
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as transaction_count,
        COALESCE(SUM(total_amount), 0) as total_sales
      FROM sales
      WHERE sale_date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    // Total items sold
    final itemsResult = await db.rawQuery('''
      SELECT COALESCE(SUM(quantity), 0) as total_items
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    // Top products
    final topProducts = await db.rawQuery('''
      SELECT 
        product_name,
        SUM(quantity) as quantity_sold,
        SUM(total_price) as total_revenue
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date BETWEEN ? AND ?
      GROUP BY product_name
      ORDER BY quantity_sold DESC
      LIMIT 10
    ''', [start.toIso8601String(), end.toIso8601String()]);

    // Daily sales
    final dailySales = await db.rawQuery('''
      SELECT 
        DATE(sale_date) as date,
        SUM(total_amount) as amount
      FROM sales
      WHERE sale_date BETWEEN ? AND ?
      GROUP BY DATE(sale_date)
      ORDER BY date ASC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return {
      'total_sales': result.first['total_sales'],
      'transaction_count': result.first['transaction_count'],
      'total_items': itemsResult.first['total_items'],
      'top_products': topProducts,
      'daily_sales': dailySales,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
