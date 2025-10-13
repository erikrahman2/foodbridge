import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  void addNotification({
    required String title,
    required String message,
    required String type,
    String? orderId,
    String? status,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'title': title,
      'message': message,
      'time': _getTimeAgo(DateTime.now()),
      'isRead': false,
      'orderId': orderId,
      'status': status,
      'timestamp': DateTime.now(),
    });
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index >= 0) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    notifyListeners();
  }

  void paymentSuccessful(String orderId) {
    addNotification(
      title: 'Payment Successful',
      message:
          'Thank you for your order! Your payment has been successfully processed.',
      type: 'payment_success',
      orderId: orderId,
      status: 'paid',
    );
  }

  void orderConfirmed(String orderId) {
    addNotification(
      title: 'Order Confirmed',
      message: 'Your order #$orderId has been confirmed and is being prepared.',
      type: 'order_update',
      orderId: orderId,
      status: 'confirmed',
    );
  }

  void orderPreparing(String orderId) {
    addNotification(
      title: 'Order Preparing',
      message: 'Your order #$orderId is being prepared by the restaurant.',
      type: 'order_update',
      orderId: orderId,
      status: 'preparing',
    );
  }

  void orderReady(String orderId) {
    addNotification(
      title: 'Order Ready',
      message:
          'Your order #$orderId is ready for pickup. Driver is on the way.',
      type: 'order_update',
      orderId: orderId,
      status: 'pickup',
    );
  }

  void orderDelivered(String orderId) {
    addNotification(
      title: 'Order Delivered',
      message:
          'Your order #$orderId has been delivered successfully. Enjoy your meal!',
      type: 'order_update',
      orderId: orderId,
      status: 'delivered',
    );
  }

  void orderCancelled(String orderId, String reason) {
    addNotification(
      title: 'Order Cancelled',
      message: 'Your order #$orderId has been cancelled. Reason: $reason',
      type: 'order_update',
      orderId: orderId,
      status: 'cancelled',
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void updateNotificationTimes() {
    for (var notification in _notifications) {
      if (notification['timestamp'] != null) {
        notification['time'] = _getTimeAgo(notification['timestamp']);
      }
    }
    notifyListeners();
  }
}
