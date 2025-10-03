import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get totalItems =>
      _cartItems.fold(0, (total, item) => total + (item['quantity'] as int));

  double get totalPrice => _cartItems.fold(
    0.0,
    (total, item) =>
        total + ((item['price'] as int) * (item['quantity'] as int)),
  );

  void addToCart(Map<String, dynamic> food, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id'] == food['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex]['quantity'] += quantity;
    } else {
      _cartItems.add({...food, 'quantity': quantity});
    }
    notifyListeners();
  }

  void removeFromCart(int foodId) {
    _cartItems.removeWhere((item) => item['id'] == foodId);
    notifyListeners();
  }

  void updateQuantity(int foodId, int quantity) {
    final index = _cartItems.indexWhere((item) => item['id'] == foodId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
