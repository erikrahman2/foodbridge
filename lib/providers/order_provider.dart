import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _currentOrder;

  List<Map<String, dynamic>> get orders => _orders;
  Map<String, dynamic>? get currentOrder => _currentOrder;

  void createOrder(
    List<Map<String, dynamic>> items,
    double totalPrice,
    void Function(String orderId)? onOrderCreated,
  ) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final order = {
      'id': orderId,
      'items': items,
      'totalPrice': totalPrice,
      'status': 'Preparing',
      'orderTime': DateTime.now(),
      'estimatedDelivery': DateTime.now().add(const Duration(minutes: 30)),
      'deliveryAddress': 'No. 1 Bungo Pasang',
    };

    _orders.insert(0, order);
    _currentOrder = order;
    notifyListeners();

    // panggil callback kalau ada
    if (onOrderCreated != null) {
      onOrderCreated(orderId);
    }
  }

  void updateOrderStatus(String orderId, String status) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index >= 0) {
      _orders[index]['status'] = status;
      if (_currentOrder?['id'] == orderId) {
        _currentOrder!['status'] = status;
      }
      notifyListeners();
    }
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}
