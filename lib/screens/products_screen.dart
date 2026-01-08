import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/services/database_service.dart';
import 'package:pos_app/utils/cart_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final db = context.read<DatabaseService>();
    final products = await db.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _showBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _BarcodeScannerScreen(
          onBarcodeDetected: (barcode) async {
            final db = context.read<DatabaseService>();
            final product = await db.getProductByBarcode(barcode);
            
            if (product != null && mounted) {
              final cartProvider = context.read<CartProvider>();
              cartProvider.addProduct(product);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} ခြင်းထဲ ထည့်ပြီးပါပြီ')),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ပစ္စည်းမတွေ့ပါ')),
              );
            }
            
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final barcodeController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ပစ္စည်းအသစ်ထည့်ရန်'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'အမည်'),
              ),
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(labelText: 'ဘားကုဒ်'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'ဈေး'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'လက်ကျန်'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('မလုပ်တော့'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty || barcodeController.text.isEmpty) {
                return;
              }

              final product = Product(
                name: nameController.text,
                barcode: barcodeController.text,
                price: double.tryParse(priceController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
              );

              final db = context.read<DatabaseService>();
              await db.insertProduct(product);
              
              if (mounted) {
                Navigator.pop(context);
                _loadProducts();
              }
            },
            child: const Text('သိမ်းရန်'),
          ),
        ],
      ),
    );
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _products;
    }
    return _products.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.barcode.contains(_searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပစ္စည်းများ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _showBarcodeScanner,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'ရှာရန်',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text('ပစ္စည်းမရှိပါ'))
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(product.name),
                              subtitle: Text('ဘားကုဒ်: ${product.barcode}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${numberFormat.format(product.price)} ကျပ်',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'လက်ကျန်: ${product.stock}',
                                    style: TextStyle(
                                      color: product.stock > 0 
                                        ? Colors.green 
                                        : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (product.stock > 0) {
                                  final cartProvider = context.read<CartProvider>();
                                  cartProvider.addProduct(product);
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} ခြင်းထဲ ထည့်ပြီးပါပြီ'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ပစ္စည်းကုန်နေပါပြီ'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _BarcodeScannerScreen extends StatelessWidget {
  final Function(String) onBarcodeDetected;

  const _BarcodeScannerScreen({required this.onBarcodeDetected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဘားကုဒ် စကင်ဖတ်ရန်'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final barcode = barcodes.first.rawValue;
            if (barcode != null) {
              onBarcodeDetected(barcode);
            }
          }
        },
      ),
    );
  }
}
