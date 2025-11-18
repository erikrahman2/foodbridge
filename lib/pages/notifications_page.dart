import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';
import 'package:food_bridge/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? _userId;
  bool _loadingUserId = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _loadingUserId = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .limit(30)
                  .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Belum ada notifikasi.'));
                  }
                  final notifDocs = snapshot.data!.docs;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notifDocs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildTodayLabel();
                      }
                      final data = notifDocs[index - 1].data() as Map<String, dynamic>;
                      return _buildNotificationItem({
                        'title': data['title'] ?? '',
                        'message': data['message'] ?? '',
                        'isRead': data['isRead'] ?? data['read'] ?? false,
                        'createdAt': data['createdAt'],
                        'type': data['type'] ?? '',
                        'orderId': data['metadata']?['orderId'] ?? data['orderId'] ?? '',
                        'status': data['metadata']?['status'] ?? data['status'] ?? '',
                      });
                    },
                  );
                },
              ),
            ),
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Text(
              'Notification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Search',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLabel() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 15),
      child: Text(
        'Today',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    // Format waktu
    String timeStr = '';
    if (notification['createdAt'] != null) {
      try {
        final ts = notification['createdAt'];
        DateTime dt;
        if (ts is Timestamp) {
          dt = ts.toDate();
        } else if (ts is DateTime) {
          dt = ts;
        } else if (ts is String) {
          dt = DateTime.tryParse(ts) ?? DateTime.now();
        } else {
          dt = DateTime.now();
        }
        timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {
        timeStr = '';
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
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
                  Text(
                    notification['title'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          notification['isRead'] == true
                              ? FontWeight.w500
                              : FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
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
          iconData = Icons.shopping_bag;
          iconColor = Colors.green;
          break;
        case 'preparing':
          iconData = Icons.restaurant;
          iconColor = Colors.orange;
          break;
        case 'pickup':
          iconData = Icons.delivery_dining;
          iconColor = Colors.blue;
          break;
        case 'delivered':
          iconData = Icons.check_circle;
          iconColor = Colors.green;
          break;
        default:
          iconData = Icons.shopping_bag;
          iconColor = Colors.green;
      }
    } else if (type == 'promotion') {
      iconData = Icons.local_offer;
      iconColor = Colors.amber;
    } else if (type == 'order_tracking') {
      iconData = Icons.location_on;
      iconColor = Colors.teal;
    } else {
      iconData = Icons.notifications;
      iconColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });

    if (notification['orderId'] != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.orderTracking,
        arguments: {
          'orderId': notification['orderId'],
          'status': notification['status'],
        },
      );
    }
  }

  void _markAllAsRead() {
    // Fungsi ini dinonaktifkan karena list notifications sudah diganti dengan data Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return CustomBottomNavigation(
          currentIndex: 3,
          notificationCount: notificationProvider.unreadCount,
        );
      },
    );
  }
}
