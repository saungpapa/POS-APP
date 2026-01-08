import 'package:flutter/material.dart';
import 'package:pos_app/models/sales_summary.dart';
import 'package:intl/intl.dart';

class ReportSummaryCard extends StatelessWidget {
  final SalesSummary summary;

  const ReportSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            icon: Icons.attach_money,
            title: 'စုစုပေါင်း',
            value: '${numberFormat.format(summary.totalSales)} ကျပ်',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            icon: Icons.receipt_long,
            title: 'အရောင်း',
            value: '${summary.transactionCount} ကြိမ်',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            icon: Icons.inventory_2,
            title: 'ပစ္စည်း',
            value: '${summary.totalItems} ခု',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
