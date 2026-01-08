import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../services/database_service.dart';
import '../models/sale.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalProducts = 0;
  int _todaySales = 0;
  double _todayRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final products = await DatabaseService.instance.getAllProducts();
    final sales = await DatabaseService.instance.getAllSales();
    
    final today = DateTime.now();
    final todaySales = sales.where((sale) {
      return sale.saleDate.year == today.year &&
             sale.saleDate.month == today.month &&
             sale.saleDate.day == today.day;
    }).toList();

    final todayRevenue = todaySales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );

    setState(() {
      _totalProducts = products.length;
      _todaySales = todaySales.length;
      _todayRevenue = todayRevenue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS App - ပင်မစာမျက်နှာ'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.store, size: 40, color: Colors.blue.shade700),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'မင်္ဂလာပါ',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'POS App သို့ ကြိုဆိုပါတယ်',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats cards
            const Text(
              'ယနေ့ အခြေအနေ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory,
                    title: 'ပစ္စည်းပေါင်း',
                    value: '$_totalProducts',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt,
                    title: 'ယနေ့ ရောင်းချမှု',
                    value: '$_todaySales',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    title: 'ယနေ့ ၀င်ငွေ',
                    value: '${numberFormat.format(_todayRevenue)} ကျပ်',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_cart,
                    title: 'ခြင်းတောင်း',
                    value: '${cartProvider.itemCount} ပစ္စည်း',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'လုပ်ဆောင်ချက်များ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _QuickActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Barcode Scan ဖတ်ရန်',
              color: Colors.blue,
              onTap: () {
                // Navigate to scanner (will be handled by bottom nav)
              },
            ),
            _QuickActionButton(
              icon: Icons.add_business,
              label: 'ပစ္စည်းအသစ် ထည့်ရန်',
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/add_product');
              },
            ),
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: 'ရောင်းချမှု မှတ်တမ်းများ',
              color: Colors.orange,
              onTap: () {
                // Navigate to sales history
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
