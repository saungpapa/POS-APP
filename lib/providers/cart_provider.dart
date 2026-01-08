import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addProduct(Product product) {
    // Check if product already exists in cart
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Increase quantity if product exists
      _items[existingIndex].increaseQuantity();
    } else {
      // Add new item
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void increaseQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].increaseQuantity();
      notifyListeners();
    }
  }

  void decreaseQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].decreaseQuantity();
      notifyListeners();
    }
  }

  /// Updates the quantity of an item at the specified index.
  /// 
  /// Note: This method does not validate against product stock.
  /// Callers are responsible for ensuring the quantity does not exceed
  /// available stock to prevent overselling.
  /// 
  /// Example usage:
  /// ```dart
  /// final product = cartProvider.items[index].product;
  /// final newQuantity = 5;
  /// if (newQuantity <= product.stockQuantity) {
  ///   cartProvider.updateQuantity(index, newQuantity);
  /// }
  /// ```
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
