import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sales_summary.dart';

class TopProductsList extends StatelessWidget {
  final List<TopProduct> products;

  const TopProductsList({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'အရောင်းမှတ်တမ်း မရှိသေးပါ',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
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
            title: Text(
              product.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${numberFormat.format(product.totalRevenue)} ကျပ်'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${product.quantitySold} ခု',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}
