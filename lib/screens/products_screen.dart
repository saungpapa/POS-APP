import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final products = await DatabaseService.instance.getAllProducts();

    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ပစ္စည်းဖျက်မှု'),
        content: Text('${product.name} ကို ဖျက်မည်လား?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('မလုပ်ပါ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ဖျက်မည်'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteProduct(product.id!);
      _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ပစ္စည်းဖျက်ပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပစ္စည်းများ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 100,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ပစ္စည်းမရှိသေးပါ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          );
                          _loadProducts();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('ပစ္စည်းအသစ် ထည့်ရန်'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductScreen(
                                product: product,
                              ),
                            ),
                          );
                          _loadProducts();
                        },
                        onDelete: () => _deleteProduct(product),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );
          _loadProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('ပစ္စည်းအသစ်'),
      ),
    );
  }
}
