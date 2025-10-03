import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'type': 'order_update',
      'title': 'Order Confirmed',
      'message':
          'Your order #SP0023900 has been confirmed and is being prepared.',
      'time': '2 min ago',
      'isRead': false,
      'orderId': 'SP0023900',
      'status': 'confirmed',
    },
    {
      'id': '2',
      'type': 'order_update',
      'title': 'Order Preparing',
      'message': 'Your order #SP0023512 is being prepared by the restaurant.',
      'time': '15 min ago',
      'isRead': false,
      'orderId': 'SP0023512',
      'status': 'preparing',
    },
    {
      'id': '3',
      'type': 'order_update',
      'title': 'Order Ready for Pickup',
      'message':
          'Your order #SP0023502 is ready for pickup. Driver is on the way.',
      'time': '30 min ago',
      'isRead': true,
      'orderId': 'SP0023502',
      'status': 'pickup',
    },
    {
      'id': '4',
      'type': 'order_update',
      'title': 'Order Delivered',
      'message':
          'Your order #SP0023450 has been delivered successfully. Enjoy your meal!',
      'time': '1 hour ago',
      'isRead': true,
      'orderId': 'SP0023450',
      'status': 'delivered',
    },
    {
      'id': '5',
      'type': 'promotion',
      'title': 'Special Discount',
      'message':
          'Get 30% off on your next order! Use code SAVE30. Valid until tomorrow.',
      'time': '2 hours ago',
      'isRead': true,
      'status': 'promotion',
    },
    {
      'id': '6',
      'type': 'order_update',
      'title': 'Order Cancelled',
      'message':
          'Your order #SP0023400 has been cancelled due to restaurant unavailability.',
      'time': '1 day ago',
      'isRead': true,
      'orderId': 'SP0023400',
      'status': 'cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildNotificationsList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We\'ll notify you when something happens',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            notification['isRead']
                ? Colors.white
                : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border:
            notification['isRead']
                ? null
                : Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _onNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(
                  notification['type'],
                  notification['status'],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    notification['isRead']
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (!notification['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['time'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (notification['orderId'] != null)
                            Text(
                              '#${notification['orderId']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, String? status) {
    IconData iconData;
    Color iconColor;

    if (type == 'order_update') {
      switch (status) {
        case 'confirmed':
          iconData = Icons.check_circle;
          iconColor = Colors.green;
          break;
        case 'preparing':
          iconData = Icons.restaurant;
          iconColor = Colors.orange;
          break;
        case 'pickup':
          iconData = Icons.local_shipping;
          iconColor = Colors.blue;
          break;
        case 'delivered':
          iconData = Icons.done_all;
          iconColor = Colors.green;
          break;
        case 'cancelled':
          iconData = Icons.cancel;
          iconColor = Colors.red;
          break;
        default:
          iconData = Icons.notifications;
          iconColor = Colors.orange;
      }
    } else if (type == 'promotion') {
      iconData = Icons.local_offer;
      iconColor = Colors.purple;
    } else {
      iconData = Icons.notifications;
      iconColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });

    if (notification['orderId'] != null) {
      // Navigate to order detail page
      Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: {
          'id': notification['orderId'],
          'status': _getOrderStatus(notification['status']),
        },
      );
    }
  }

  String _getOrderStatus(String? notificationStatus) {
    switch (notificationStatus) {
      case 'confirmed':
      case 'preparing':
      case 'pickup':
        return 'Active';
      case 'delivered':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Active';
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Notifications tab is selected
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
            label: '',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.ordersHistory);
          }
          // Handle other nav items
        },
      ),
    );
  }
}
