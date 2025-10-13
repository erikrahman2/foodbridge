import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  Set<int> _selectedItemIds = {}; // Track selected items

  List<Map<String, dynamic>> get cartItems => _cartItems;
  Set<int> get selectedItemIds => _selectedItemIds;

  // Get only selected items
  List<Map<String, dynamic>> get selectedItems =>
      _cartItems
          .where((item) => _selectedItemIds.contains(item['id']))
          .toList();

  // Total items in cart
  int get totalItems =>
      _cartItems.fold(0, (total, item) => total + (item['quantity'] as int));

  // Total items selected
  int get selectedItemsCount =>
      selectedItems.fold(0, (total, item) => total + (item['quantity'] as int));

  // Total price of all items
  double get totalPrice => _cartItems.fold(
    0.0,
    (total, item) =>
        total + ((item['price'] as int) * (item['quantity'] as int)),
  );

  // Total price of selected items only
  double get selectedTotalPrice => selectedItems.fold(
    0.0,
    (total, item) =>
        total + ((item['price'] as int) * (item['quantity'] as int)),
  );

  // Check if item is selected
  bool isItemSelected(int foodId) => _selectedItemIds.contains(foodId);

  // Toggle item selection
  void toggleItemSelection(int foodId, bool isSelected) {
    if (isSelected) {
      _selectedItemIds.add(foodId);
    } else {
      _selectedItemIds.remove(foodId);
    }
    notifyListeners();
  }

  // Select all items
  void selectAllItems() {
    _selectedItemIds = _cartItems.map((item) => item['id'] as int).toSet();
    notifyListeners();
  }

  // Deselect all items
  void deselectAllItems() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  // Check if all items are selected
  bool get areAllItemsSelected =>
      _cartItems.isNotEmpty && _selectedItemIds.length == _cartItems.length;

  void addToCart(Map<String, dynamic> food, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id'] == food['id'],
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex]['quantity'] += quantity;
    } else {
      _cartItems.add({...food, 'quantity': quantity});
      // Auto-select new item
      _selectedItemIds.add(food['id']);
    }
    notifyListeners();
  }

  void removeFromCart(int foodId) {
    _cartItems.removeWhere((item) => item['id'] == foodId);
    _selectedItemIds.remove(foodId);
    notifyListeners();
  }

  void updateQuantity(int foodId, int quantity) {
    final index = _cartItems.indexWhere((item) => item['id'] == foodId);
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

  // Clear only selected items (for checkout)
  void clearSelectedItems() {
    _cartItems.removeWhere((item) => _selectedItemIds.contains(item['id']));
    _selectedItemIds.clear();
    notifyListeners();
  }
}
