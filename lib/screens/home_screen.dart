import 'package:flutter/material.dart';
import 'package:pos_app/screens/products_screen.dart';
import 'package:pos_app/screens/cart_screen.dart';
import 'package:pos_app/screens/sales_report_screen.dart';
import 'package:pos_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProductsScreen(),
    const CartScreen(),
    const SalesReportScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'ပစ္စည်းများ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'ခြင်း',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'အရောင်းစာရင်း',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ဆက်တင်',
          ),
        ],
      ),
    );
  }
}
