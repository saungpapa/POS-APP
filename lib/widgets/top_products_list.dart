import 'package:flutter/material.dart';
import 'package:pos_app/models/sales_summary.dart';
import 'package:intl/intl.dart';

class TopProductsList extends StatelessWidget {
  final List<TopProduct> topProducts;

  const TopProductsList({super.key, required this.topProducts});

  @override
  Widget build(BuildContext context) {
    if (topProducts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('အရောင်းဒေတာ မရှိပါ'),
          ),
        ),
      );
    }

    final numberFormat = NumberFormat('#,###');

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topProducts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = topProducts[index];
          final rank = index + 1;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(rank),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(product.productName),
            subtitle: Text(
              'အရေအတွက်: ${product.quantitySold} ခု',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${numberFormat.format(product.totalRevenue)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'ကျပ်',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }
}
