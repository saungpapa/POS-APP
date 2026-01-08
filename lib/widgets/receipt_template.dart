import 'package:flutter/material.dart';
import 'package:pos_app/models/receipt.dart';
import 'package:intl/intl.dart';

class ReceiptTemplate extends StatelessWidget {
  final Receipt receipt;

  const ReceiptTemplate({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name
          Center(
            child: Text(
              receipt.shopName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Date and time
          Center(
            child: Text('ရက်စွဲ: ${dateFormat.format(receipt.dateTime)}'),
          ),
          
          // Receipt number
          Center(
            child: Text('ဘောက်ချာ: ${receipt.receiptNumber}'),
          ),
          
          const Divider(height: 24, thickness: 1),
          
          // Column headers
          Row(
            children: [
              const Expanded(
                flex: 5,
                child: Text(
                  'ပစ္စည်း',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'အရေအတွက်',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'ဈေး',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          
          const Divider(height: 16, thickness: 1),
          
          // Items
          ...receipt.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(item.productName),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    item.quantity.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    numberFormat.format(item.totalPrice),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          )),
          
          const Divider(height: 24, thickness: 1),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'စုစုပေါင်း',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${numberFormat.format(receipt.totalAmount)} ကျပ်',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Thank you message
          const Center(
            child: Text(
              'ကျေးဇူးတင်ပါသည်',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
