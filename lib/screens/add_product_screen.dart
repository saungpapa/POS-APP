import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  final String? barcode;

  const AddProductScreen({
    super.key,
    this.product,
    this.barcode,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(
      text: widget.product?.barcode ?? widget.barcode ?? '',
    );
    _nameController = TextEditingController(
      text: widget.product?.name ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: widget.product?.id,
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stockQuantity: int.parse(_stockController.text.trim()),
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (widget.product == null) {
        // Create new product
        await DatabaseService.instance.createProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ပစ္စည်းအသစ် ထည့်ပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing product
        await DatabaseService.instance.updateProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ပစ္စည်း ပြင်ဆင်ပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အမှား: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'ပစ္စည်းအသစ် ထည့်ရန်' : 'ပစ္စည်း ပြင်ဆင်ရန်',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Barcode field
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode *',
                hintText: 'Barcode ထည့်ပါ',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Barcode ထည့်ပေးပါ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ပစ္စည်းအမည် *',
                hintText: 'ပစ္စည်းအမည် ထည့်ပါ',
                prefixIcon: Icon(Icons.shopping_bag),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ပစ္စည်းအမည် ထည့်ပေးပါ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price field
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'ဈေးနှုန်း (ကျပ်) *',
                hintText: 'ဈေးနှုန်း ထည့်ပါ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ဈေးနှုန်း ထည့်ပေးပါ';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'မှန်ကန်သော ဈေးနှုန်း ထည့်ပေးပါ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stock quantity field
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'လက်ကျန်အရေအတွက် *',
                hintText: 'လက်ကျန် ထည့်ပါ',
                prefixIcon: Icon(Icons.inventory),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'လက်ကျန်အရေအတွက် ထည့်ပေးပါ';
                }
                final stock = int.tryParse(value);
                if (stock == null || stock < 0) {
                  return 'မှန်ကန်သော အရေအတွက် ထည့်ပေးပါ';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.product == null ? 'ထည့်မည်' : 'ပြင်ဆင်မည်',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
