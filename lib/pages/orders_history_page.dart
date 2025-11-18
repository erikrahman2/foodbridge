// lib/pages/orders_history_page.dart - FIXED VERSION with Title Display
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<String> filters = ['All', 'Delivering', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startListeningAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              'Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search orders...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.tune, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          final orderProvider = context.watch<OrderProvider>();
          final count = _getOrderCountForFilter(orderProvider.orders, filter);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Icon(Icons.check, color: Colors.white, size: 16),
                  if (isSelected) const SizedBox(width: 6),
                  Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (filter != 'All' && count > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _getOrderCountForFilter(
    List<Map<String, dynamic>> orders,
    String filter,
  ) {
    if (filter == 'All') return orders.length;
    if (filter == 'Delivering') {
      return orders
          .where(
            (order) =>
                order['status'] == 'Prepared' ||
                order['status'] == 'Delivering',
          )
          .length;
    }
    return orders.where((order) => order['status'] == filter).length;
  }

  Widget _buildOrdersList() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        var filteredOrders = _getFilteredOrders(orderProvider.orders);

        if (searchQuery.isNotEmpty) {
          filteredOrders =
              filteredOrders.where((order) {
                final orderId = order['id'].toString().toLowerCase();
                final status = order['status'].toString().toLowerCase();

                // Search in items titles
                final items = order['items'] as List?;
                if (items != null) {
                  for (var item in items) {
                    if (item is Map) {
                      final title =
                          (item['title'] ?? '').toString().toLowerCase();
                      if (title.contains(searchQuery)) return true;
                    }
                  }
                }

                return orderId.contains(searchQuery) ||
                    status.contains(searchQuery);
              }).toList();
        }

        if (filteredOrders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: filteredOrders.length,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredOrders(
    List<Map<String, dynamic>> orders,
  ) {
    if (selectedFilter == 'All') {
      return orders;
    } else if (selectedFilter == 'Delivering') {
      return orders
          .where(
            (order) =>
                order['status'] == 'Prepared' ||
                order['status'] == 'Delivering',
          )
          .toList();
    }
    return orders.where((order) => order['status'] == selectedFilter).toList();
  }

  Widget _buildEmptyState() {
    String emptyMessage = 'No orders found';
    String emptySubtitle = 'Your orders will appear here';

    if (selectedFilter != 'All') {
      emptyMessage = 'No ${selectedFilter.toLowerCase()} orders';
      emptySubtitle =
          'You don\'t have any ${selectedFilter.toLowerCase()} orders yet';
    }

    if (searchQuery.isNotEmpty) {
      emptyMessage = 'No results found';
      emptySubtitle = 'Try searching with different keywords';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            emptySubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty && selectedFilter == 'All') ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.menuList);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Browse Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderImage = order['image'] as String?;
    final status = order['status'] as String? ?? 'Delivering';

    // Parse items dengan aman
    List<Map<String, dynamic>> items = [];
    if (order['items'] != null) {
      try {
        final itemsRaw = order['items'];
        if (itemsRaw is List) {
          items =
              itemsRaw.map((e) {
                if (e is Map) {
                  return Map<String, dynamic>.from(e as Map);
                }
                return <String, dynamic>{};
              }).toList();
        }
      } catch (e) {
        print('Error parsing items: $e');
      }
    }

    final itemCount = items.length;
    final totalPrice =
        (order['totalPrice'] is num) ? (order['totalPrice'] as num).toInt() : 0;
    final rating =
        (order['rating'] is num) ? (order['rating'] as num).toDouble() : 5.0;

    // Get first item title untuk display
    String firstItemTitle = 'Order';
    if (items.isNotEmpty) {
      firstItemTitle = items.first['title']?.toString() ?? 'Order';
    }

    // Jika ada lebih dari 1 item, tambahkan info
    String orderTitle = firstItemTitle;
    if (itemCount > 1) {
      orderTitle = '$firstItemTitle +${itemCount - 1} more';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.orderDetail,
              arguments: order,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildOrderImages(orderImage, items),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderTitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Order ID: ${order['id'] ?? '-'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_formatPrice(totalPrice)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star,
                              size: 14,
                              color:
                                  starIndex < rating
                                      ? Colors.orange
                                      : Colors.grey[300],
                            );
                          }),
                          const SizedBox(width: 8),
                          if (itemCount > 0)
                            Text(
                              '• $itemCount item${itemCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
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

  Widget _buildOrderImages(
    String? mainImage,
    List<Map<String, dynamic>> items,
  ) {
    if (items.length > 1) {
      return SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          children: [
            for (int i = 0; i < (items.length > 3 ? 3 : items.length); i++)
              Positioned(
                left: i * 15.0,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImage(items[i]['image']),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImage(mainImage),
        ),
      );
    }
  }

  Widget _buildImage(dynamic imagePath) {
    final imageStr = imagePath?.toString() ?? '';
    if (imageStr.isNotEmpty) {
      return Image.asset(
        imageStr,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.fastfood, color: Colors.grey[400], size: 30);
        },
      );
    }
    return Icon(Icons.fastfood, color: Colors.grey[400], size: 30);
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivering':
      case 'Prepared':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBottomNavBar() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return CustomBottomNavigation(
          currentIndex: 1,
          notificationCount: notificationProvider.unreadCount,
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
