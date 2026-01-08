import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';

class ReceiptTemplate extends StatelessWidget {
  final Receipt receipt;

  const ReceiptTemplate({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Receipt number
          Center(
            child: Text(
              'ဘောက်ချာ #${receipt.receiptNumber}',
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Date and time
          Center(
            child: Text(
              '${receipt.formattedDate} ${receipt.formattedTime}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Divider(height: 24, thickness: 2),

          // Items header
          Row(
            children: [
              const Expanded(
                flex: 4,
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
                flex: 2,
                child: Text(
                  'ဈေး',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Items
          ...receipt.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(item.product.name),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      numberFormat.format(item.totalPrice),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 24, thickness: 2),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'စုစုပေါင်း:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${numberFormat.format(receipt.sale.totalAmount)} ကျပ်',
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
              'ကျေးဇူးတင်ပါတယ်!',
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
