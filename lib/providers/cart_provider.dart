// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  Set<String> _selectedItemIds = {}; // Changed from int to String

  List<Map<String, dynamic>> get cartItems => _cartItems;
  Set<String> get selectedItemIds => _selectedItemIds;

  List<Map<String, dynamic>> get selectedItems =>
      _cartItems
          .where((item) => _selectedItemIds.contains(item['id'].toString()))
          .toList();

  int get totalItems =>
      _cartItems.fold(0, (total, item) => total + (item['quantity'] as int));

  int get selectedItemsCount =>
      selectedItems.fold(0, (total, item) => total + (item['quantity'] as int));

  double get totalPrice => _cartItems.fold(
        0.0,
        (total, item) =>
            total + ((item['price'] as int) * (item['quantity'] as int)),
      );

  double get selectedTotalPrice => selectedItems.fold(
        0.0,
        (total, item) =>
            total + ((item['price'] as int) * (item['quantity'] as int)),
      );

  bool isItemSelected(String foodId) => _selectedItemIds.contains(foodId);

  void toggleItemSelection(String foodId, bool isSelected) {
    if (isSelected) {
      _selectedItemIds.add(foodId);
    } else {
      _selectedItemIds.remove(foodId);
    }
    notifyListeners();
  }

  void selectAllItems() {
    _selectedItemIds = _cartItems.map((item) => item['id'].toString()).toSet();
    notifyListeners();
  }

  void deselectAllItems() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  bool get areAllItemsSelected =>
      _cartItems.isNotEmpty && _selectedItemIds.length == _cartItems.length;

  void addToCart(Map<String, dynamic> food, {int quantity = 1}) {
    final foodId = food['id'].toString();
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id'].toString() == foodId,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex]['quantity'] += quantity;
    } else {
      _cartItems.add({...food, 'quantity': quantity});
      _selectedItemIds.add(foodId);
    }
    notifyListeners();
  }

  void removeFromCart(String foodId) {
    _cartItems.removeWhere((item) => item['id'].toString() == foodId);
    _selectedItemIds.remove(foodId);
    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    final index = _cartItems.indexWhere((item) => item['id'].toString() == foodId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
        _selectedItemIds.remove(foodId);
      } else {
        _cartItems[index]['quantity'] = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _selectedItemIds.clear();
    notifyListeners();
  }

  void clearSelectedItems() {
    _cartItems.removeWhere((item) => _selectedItemIds.contains(item['id'].toString()));
    _selectedItemIds.clear();
    notifyListeners();
  }
}