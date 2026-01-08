import 'package:flutter/foundation.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/models/sale.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addProduct(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeProduct(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Sale createSale(String receiptNumber) {
    final saleItems = _items.map((cartItem) => SaleItem(
      productId: cartItem.product.id!,
      productName: cartItem.product.name,
      quantity: cartItem.quantity,
      unitPrice: cartItem.product.price,
      totalPrice: cartItem.totalPrice,
    )).toList();

    return Sale(
      receiptNumber: receiptNumber,
      saleDate: DateTime.now(),
      totalAmount: totalAmount,
      items: saleItems,
    );
  }
}
