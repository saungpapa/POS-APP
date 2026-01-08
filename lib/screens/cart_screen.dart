import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../services/database_service.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _completeSale(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ခြင်းတောင်းတွင် ပစ္စည်းမရှိပါ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm sale
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ရောင်းချမှု ပြီးစီးမှု'),
        content: Text(
          'စုစုပေါင်း: ${NumberFormat('#,###').format(cartProvider.totalAmount)} ကျပ်\n\nရောင်းချမှု ပြီးစီးမှု အတည်ပြုမည်လား?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('မလုပ်ပါ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('အတည်ပြုမည်'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Create sale
      final sale = Sale(
        totalAmount: cartProvider.totalAmount,
        saleDate: DateTime.now(),
      );

      final saleItems = cartProvider.items.map((item) {
        return SaleItem(
          saleId: 0, // Will be set by database
          productId: item.product.id!,
          quantity: item.quantity,
          unitPrice: item.product.price,
        );
      }).toList();

      await DatabaseService.instance.createSale(sale, saleItems);

      // Clear cart
      cartProvider.clear();

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ရောင်းချမှု အောင်မြင်ပါသည်'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အမှား: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ခြင်းတောင်း'),
        actions: [
          if (cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ခြင်းတောင်း ရှင်းလင်းမှု'),
                    content: const Text('ခြင်းတောင်းထဲရှိ ပစ္စည်းအားလုံး ဖယ်ရှားမည်လား?'),
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
                        child: const Text('ရှင်းလင်းမည်'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  cartProvider.clear();
                }
              },
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ခြင်းတောင်းတွင် ပစ္စည်းမရှိပါ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scanner သုံးပြီး ပစ္စည်းထည့်ပါ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return CartItemTile(
                        item: item,
                        onIncrease: () => cartProvider.increaseQuantity(index),
                        onDecrease: () => cartProvider.decreaseQuantity(index),
                        onRemove: () => cartProvider.removeItem(index),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ပစ္စည်းအရေအတွက်:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${cartProvider.itemCount} မျိုး',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'စုစုပေါင်း:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${numberFormat.format(cartProvider.totalAmount)} ကျပ်',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _completeSale(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'ရောင်းချမှု ပြီးစီးမှု',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
