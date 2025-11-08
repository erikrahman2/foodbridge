import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_bridge/services/order_services.dart';

class OrderProvider extends ChangeNotifier {
  final OrdersService _service = OrdersService();

  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _currentOrder;

  StreamSubscription<List<Map<String, dynamic>>>? _ordersSub;
  Timer? _autoTimer;

  List<Map<String, dynamic>> get orders => _orders;
  Map<String, dynamic>? get currentOrder => _currentOrder;

  Stream<List<Map<String, dynamic>>> streamOrdersSafe() {
    return _service.streamOrders();
  }

  void startListeningAllOrders() {
    _ordersSub?.cancel();
    _ordersSub = _service.streamOrders().listen(
      (list) {
        _orders = list;
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) print('Orders stream error: $e');
      },
    );

    _startAutoTransition();
  }

  void startListeningByStatus(String status) {
    _ordersSub?.cancel();
    if (status == 'All') {
      startListeningAllOrders();
      return;
    }

    _ordersSub = _service
        .streamOrdersByStatus(status)
        .listen(
          (list) {
            _orders = list;
            notifyListeners();
          },
          onError: (e) {
            if (kDebugMode) print('Orders by status stream error: $e');
          },
        );

    _startAutoTransition();
  }

  /// Create order using payload Map
  Future<String> createOrder(Map<String, dynamic> payload) async {
    final id = await _service.createOrder(payload);

    // Fetch the created order back
    Map<String, dynamic>? fetched;
    int tries = 0;
    while (tries < 6) {
      fetched = await _service.getOrderOnce(id);
      if (fetched != null && fetched['createdAt'] != null) break;
      await Future.delayed(const Duration(milliseconds: 300));
      tries++;
    }

    // Set current order and add to local list
    _currentOrder = fetched;
    if (_currentOrder != null) {
      _orders.removeWhere((o) => o['id'] == id);
      _orders.insert(0, _currentOrder!);
    }
    notifyListeners();
    return id;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _service.updateOrder(orderId, {'status': status});
    final idx = _orders.indexWhere((o) => o['id'] == orderId);
    if (idx >= 0) {
      _orders[idx]['status'] = status;
    }
    if (_currentOrder?['id'] == orderId) {
      _currentOrder!['status'] = status;
    }
    notifyListeners();
  }

  Future<void> refreshOrder(String orderId) async {
    _currentOrder = await _service.getOrderOnce(orderId);
    notifyListeners();
  }

  Future<void> deleteOrder(String orderId) async {
    await _service.deleteOrder(orderId);
    _orders.removeWhere((o) => o['id'] == orderId);
    if (_currentOrder?['id'] == orderId) _currentOrder = null;
    notifyListeners();
  }

  void clear() {
    _ordersSub?.cancel();
    _autoTimer?.cancel();
    _orders = [];
    _currentOrder = null;
    notifyListeners();
  }

  void _startAutoTransition() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final now = DateTime.now();
      final ordersCopy = List<Map<String, dynamic>>.from(_orders);
      for (var order in ordersCopy) {
        final status = (order['status'] ?? 'Delivering') as String;
        final createdAt = order['createdAt'];
        if (createdAt is Timestamp) {
          final created = createdAt.toDate();
          final diff = now.difference(created);

          if (status == 'Delivering' && diff > const Duration(minutes: 1)) {
            try {
              await updateOrderStatus(order['id'] as String, 'Completed');
            } catch (e) {
              if (kDebugMode) print('Auto update to Completed failed: $e');
            }
          }

          if (status == 'Completed' && diff > const Duration(days: 1)) {
            try {
              await updateOrderStatus(order['id'] as String, 'Cancelled');
            } catch (e) {
              if (kDebugMode) print('Auto update to Cancelled failed: $e');
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _autoTimer?.cancel();
    super.dispose();
  }
}
