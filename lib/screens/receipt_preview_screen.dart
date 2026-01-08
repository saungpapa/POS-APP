import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/receipt.dart';
import '../models/sale.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../widgets/receipt_template.dart';
import '../services/print_service.dart';
import '../services/pdf_service.dart';
import 'printer_settings_screen.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final Sale sale;
  final List<CartItem> cartItems;
  final String shopName;

  const ReceiptPreviewScreen({
    super.key,
    required this.sale,
    required this.cartItems,
    this.shopName = 'ကျွန်ုပ်တို့၏ ဆိုင်',
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final PrintService _printService = PrintService.instance;
  final PdfService _pdfService = PdfService.instance;
  bool _isPrinting = false;

  Receipt get _receipt {
    return Receipt(
      sale: widget.sale,
      items: widget.cartItems.map((cartItem) {
        return ReceiptItem(
          product: cartItem.product,
          quantity: cartItem.quantity,
          unitPrice: cartItem.product.price,
        );
      }).toList(),
      shopName: widget.shopName,
      receiptNumber: widget.sale.id?.toString() ?? '0',
    );
  }

  Future<void> _printReceipt() async {
    if (_printService.selectedPrinter == null) {
      // No printer selected, show settings
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PrinterSettingsScreen(),
        ),
      );

      if (_printService.selectedPrinter == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Printer မရွေးချယ်ရသေးပါ'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      await _printService.printReceipt(_receipt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ပရင့်ထုတ် အောင်မြင်ပါသည်'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ပရင့်မထုတ်နိုင်ပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  Future<void> _savePdf() async {
    try {
      final pdf = await _pdfService.generateReceiptPdf(_receipt);
      await _pdfService.printPdf(pdf);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ဖန်တီးပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF မဖန်တီးနိုင်ပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    try {
      final pdf = await _pdfService.generateReceiptPdf(_receipt);
      await _pdfService.sharePdf(
        pdf,
        'receipt_${widget.sale.id}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('မျှဝေ၍ မရပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဘောက်ချာ ကြိုတင်ကြည့်ရှုခြင်း'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Receipt preview
            Center(
              child: ReceiptTemplate(receipt: _receipt),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Print to Bluetooth
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isPrinting ? null : _printReceipt,
                      icon: _isPrinting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.print),
                      label: Text(_isPrinting ? 'ပရင့်ထုတ်နေသည်...' : 'Bluetooth Printer သို့ ပရင့်ထုတ်မည်'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Save/View PDF
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _savePdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF အဖြစ် ကြည့်ရှုမည်'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Share
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _sharePdf,
                      icon: const Icon(Icons.share),
                      label: const Text('မျှဝေမည်'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Printer Settings
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrinterSettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Printer ချိတ်ဆက်မှု'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
