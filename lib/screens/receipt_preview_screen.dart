import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/models/receipt.dart';
import 'package:pos_app/services/database_service.dart';
import 'package:pos_app/services/pdf_service.dart';
import 'package:pos_app/utils/cart_provider.dart';
import 'package:pos_app/widgets/receipt_template.dart';
import 'package:pos_app/screens/printer_settings_screen.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  const ReceiptPreviewScreen({super.key});

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  Receipt? _receipt;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    final db = context.read<DatabaseService>();
    final cart = context.read<CartProvider>();
    
    // Generate receipt number
    final now = DateTime.now();
    final receiptNumber = 'R${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour}${now.minute}${now.second}';
    
    // Get shop name
    final shopName = await db.getSetting('shop_name', defaultValue: 'ကျွန်တော့်ဆိုင်');
    
    // Create sale
    final sale = cart.createSale(receiptNumber);
    
    setState(() {
      _receipt = Receipt.fromSale(sale, shopName);
      _isLoading = false;
    });
  }

  Future<void> _completeSale() async {
    if (_receipt == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final db = context.read<DatabaseService>();
      final cart = context.read<CartProvider>();
      
      final sale = cart.createSale(_receipt!.receiptNumber);
      await db.insertSale(sale);
      
      cart.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('အရောင်းပြီးပါပြီ')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('အမှား: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _printReceipt() async {
    if (_receipt == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrinterSettingsScreen(receipt: _receipt!),
      ),
    ).then((printed) {
      if (printed == true) {
        _completeSale();
      }
    });
  }

  Future<void> _savePdf() async {
    if (_receipt == null) return;

    try {
      final pdfService = PdfService();
      await pdfService.shareReceiptPdf(_receipt!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF သိမ်းပြီးပါပြီ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('အမှား: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဘောက်ချာ ကြိုတင်ကြည့်ရှုရန်'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_receipt != null) ReceiptTemplate(receipt: _receipt!),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _savePdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF သိမ်းရန်'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _printReceipt,
                          icon: const Icon(Icons.print),
                          label: const Text('ပရင့်ထုတ်မယ်'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _completeSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'ပရင့်မထုတ်ဘဲ ပြီးမယ်',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
