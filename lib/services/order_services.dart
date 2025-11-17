import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  final CollectionReference _orders = FirebaseFirestore.instance.collection(
    'orders',
  );

  /// Stream semua orders — realtime listener
  Stream<List<Map<String, dynamic>>> streamOrders() {
    return _orders.orderBy('createdAt', descending: true).snapshots().map((
      snap,
    ) {
      return snap.docs.map((doc) {
        final d = (doc.data() as Map<String, dynamic>);
        d['id'] = doc.id;
        return d;
      }).toList();
    });
  }

  /// Stream berdasarkan status (Delivering, Completed, Cancelled)
  Stream<List<Map<String, dynamic>>> streamOrdersByStatus(String status) {
    if (status == 'All') return streamOrders();
    return _orders
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) {
                final d = (doc.data() as Map<String, dynamic>);
                d['id'] = doc.id;
                return d;
              }).toList(),
        );
  }

  /// Create order — perhitungan yang konsisten dengan payment_page
  Future<String> createOrder(Map<String, dynamic> payload) async {
    final docRef = _orders.doc();
    final id = docRef.id;

    final items = List<Map<String, dynamic>>.from(payload['items'] ?? []);

    // Hitung subtotal dari items
    int subtotal = 0;
    for (var item in items) {
      final price = (item['price'] is num) ? (item['price'] as num).toInt() : 0;
      final qty =
          (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 1;
      subtotal += price * qty;
    }

    // Ambil nilai dari payload atau gunakan default
    final int deliveryFee =
        (payload['deliveryFee'] is num)
            ? (payload['deliveryFee'] as num).toInt()
            : 5000;

    final int discount =
        (payload['discount'] is num)
            ? (payload['discount'] as num).toInt()
            : ((subtotal * 0.1).round()); // 10% default

    // Tax 1% dari (subtotal - discount)
    final int tax =
        (payload['tax'] is num)
            ? (payload['tax'] as num).toInt()
            : (((subtotal - discount) * 0.01).round());

    // Total = subtotal + deliveryFee + tax - discount
    final int totalPrice =
        (payload['totalPrice'] is num)
            ? (payload['totalPrice'] as num).toInt()
            : (subtotal + deliveryFee + tax - discount);

    // ETA: default 15-30 menit dari sekarang
    final estimatedDelivery =
        payload['estimatedDelivery'] is DateTime
            ? payload['estimatedDelivery'] as DateTime
            : DateTime.now().add(const Duration(minutes: 30));

    final now = FieldValue.serverTimestamp();

    final orderData = {
      'id': id,
      'items': items,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'tax': tax,
      'totalPrice': totalPrice,
      'paymentMethod': payload['paymentMethod'] ?? 'Cash on Delivery',
      'deliveryAddress':
          payload['deliveryAddress'] ??
          'No. 1 Bungo Pasang, Padang, West Sumatra',
      'customerId': payload['customerId'] ?? 'user_123',
      'merchantId': payload['merchantId'] ?? '',
      'driverId': payload['driverId'] ?? '',
      'driverLatitude': payload['driverLatitude'] ?? 0.0,
      'driverLongitude': payload['driverLongitude'] ?? 0.0,
      'eta': payload['eta'] ?? '30 minutes',
      'status': payload['status'] ?? 'Delivering',
      'rating': payload['rating'] ?? 5.0,
      'createdAt': now,
      'updatedAt': now,
      'estimatedDelivery': estimatedDelivery,
      // Tambahan info untuk UI
      'image':
          items.isNotEmpty && items.first.containsKey('image')
              ? items.first['image']
              : '',
    };

    await docRef.set(orderData);
    return id;
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> updates) async {
    // STRENGTHENED VALIDATION at service layer
    if (orderId.isEmpty) {
      print('❌ [ORDER SERVICE] updateOrder called with empty orderId');
      throw ArgumentError('Order ID tidak boleh kosong');
    }

    print('💾 [ORDER SERVICE] Updating Firestore doc: $orderId');
    print('Updates: ${updates.keys.join(", ")}');

    updates['updatedAt'] = FieldValue.serverTimestamp();

    // Explicit doc reference to ensure correct order is updated
    await _orders.doc(orderId).update(updates);

    print('✅ [ORDER SERVICE] Firestore update successful for $orderId');
  }

  Future<void> deleteOrder(String orderId) async {
    await _orders.doc(orderId).delete();
  }

  Future<Map<String, dynamic>?> getOrderOnce(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    final d = doc.data() as Map<String, dynamic>;
    d['id'] = doc.id;
    return d;
  }
}
