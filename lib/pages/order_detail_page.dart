import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<String, dynamic>? orderData;
  int userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _hasSubmittedReview = false; // Track if review has been submitted
  bool _showCompletedPattern = true; // Track if pattern should show
  Timer? _patternTimer;
  StreamSubscription<DocumentSnapshot>? _orderListener;
  String? _currentOrderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (orderData == null) {
      // If full order map provided in arguments, use it as initial data.
      if (args != null && args.containsKey('id') && args.containsKey('items')) {
        orderData = Map<String, dynamic>.from(args);
        _setupRealtimeListener(args['id'] as String);
      } else if (args != null && args.containsKey('orderId')) {
        // If only orderId passed, fetch from provider
        final orderId = args['orderId'] as String?;
        if (orderId != null) {
          context.read<OrderProvider>().refreshOrder(orderId);
          _setupRealtimeListener(orderId);
        }
      } else if (args != null && args.containsKey('id')) {
        // fallback if just id exists
        final orderId = args['id'] as String?;
        if (orderId != null) {
          context.read<OrderProvider>().refreshOrder(orderId);
          _setupRealtimeListener(orderId);
        }
      }
    }
  }

  void _setupRealtimeListener(String orderId) {
    if (_currentOrderId == orderId && _orderListener != null) {
      return; // Already listening to this order
    }

    // Cancel previous listener
    _orderListener?.cancel();
    _currentOrderId = orderId;

    print('🔔 [ORDER DETAIL] Setting up realtime listener for order: $orderId');

    // Setup Firestore realtime listener
    _orderListener = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists || !mounted) return;

          final data = snapshot.data() as Map<String, dynamic>;
          data['id'] = snapshot.id;

          final wasDeliveredByDriver = orderData?['deliveredByDriver'] == true;
          final isNowDeliveredByDriver = data['deliveredByDriver'] == true;

          print('📡 [ORDER DETAIL] Realtime update received:');
          print('   Order ID: $orderId');
          print('   Status: ${data['status']}');
          print('   deliveredByDriver: $isNowDeliveredByDriver');

          setState(() {
            orderData = data;
          });

          // Show notification if driver just marked as delivered
          if (!wasDeliveredByDriver && isNowDeliveredByDriver) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '✅ Driver telah menandai pesanan selesai! Track Order sekarang aktif.',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final providerOrder = context.watch<OrderProvider>().currentOrder;
    // Prefer provider's realtime data when available
    if (providerOrder != null) {
      orderData = providerOrder;
    }

    if (orderData == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: const Center(
          child: Text(
            'Order not found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Status card hilang, ganti pattern 3 detik
                    if ((orderData!['status'] ?? '') == 'Completed' &&
                        _showCompletedPattern)
                      _buildCompletedPattern(),
                    // Banner when driver has marked delivered
                    if ((orderData!['status'] ?? '') == 'Delivering' &&
                        orderData?['deliveredByDriver'] == true)
                      _buildDeliveredByDriverBanner(),
                    const SizedBox(height: 16),
                    _buildOrderItems(),
                    const SizedBox(height: 16),
                    _buildDeliveryInfo(),
                    const SizedBox(height: 16),
                    _buildPriceBreakdown(),
                    // Rating section hanya tampil jika Completed dan belum submit
                    if ((orderData!['status'] ?? '') == 'Completed' &&
                        !_hasSubmittedReview) ...[
                      const SizedBox(height: 16),
                      _buildRatingSection(),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeader() {
    final isDelivering = orderData!['status'] == 'Delivering';
    final isDeliveredByDriver = orderData?['deliveredByDriver'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Order ${orderData!['id'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Show indicator if delivered by driver
                    if (isDelivering && isDeliveredByDriver) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Siap Dikonfirmasi',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Refresh button
          IconButton(
            onPressed: () async {
              final orderId = orderData?['id'] ?? orderData?['orderId'];
              if (orderId != null) {
                await context.read<OrderProvider>().refreshOrder(orderId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '🔄 Data pesanan diperbarui',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.black54),
            tooltip: 'Refresh Order',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: const Text(
                      'Share Order',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {},
                  ),
                  PopupMenuItem(
                    child: const Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
          ),
        ],
      ),
    );
  }

  // Banner notification when driver has marked delivered
  Widget _buildDeliveredByDriverBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎉 Pesanan Telah Terkirim!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Driver telah menyelesaikan pengiriman.\nKlik tombol Track Order di bawah untuk konfirmasi.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pattern 3 detik untuk order completed
  Widget _buildCompletedPattern() {
    // Start timer if not already started
    _patternTimer ??= Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCompletedPattern = false;
        });
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(
            'Order Completed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    final dynamic itemsSource = orderData?['items'];
    final List<Map<String, dynamic>> items =
        (itemsSource is List)
            ? List<Map<String, dynamic>>.from(
              itemsSource.map((e) => Map<String, dynamic>.from(e as Map)),
            )
            : [
              {
                'name': 'Chicken Burger',
                'price': 59000.00,
                'originalPrice': 59000.00,
                'isAddOn': false,
                'quantity': 1,
              },
              {
                'name': 'Add Cheese',
                'price': 0,
                'originalPrice': 15000.00,
                'isAddOn': true,
                'quantity': 1,
              },
              {
                'name': 'Add Meat (Cow meat)',
                'price': 0,
                'originalPrice': 18000.00,
                'isAddOn': true,
                'quantity': 1,
              },
              {
                'name': 'Ramen Noodles',
                'price': 25000.00,
                'originalPrice': 25000.00,
                'isAddOn': false,
                'quantity': 2,
              },
              {
                'name': 'Cherry Tomato Salad',
                'price': 7000.00,
                'originalPrice': 7000.00,
                'isAddOn': false,
                'quantity': 1,
              },
            ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              _buildOrderItem(items[index]),
              if (index < items.length - 1)
                Divider(color: Colors.grey[100], height: 1, thickness: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final quantity =
        (item['quantity'] is int)
            ? item['quantity'] as int
            : (item['quantity'] is num ? (item['quantity'] as num).toInt() : 1);
    final priceNum =
        (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
    final name = item['title'] ?? item['name'] ?? 'Item';
    final imageUrl = item['imageUrl'] ?? item['image'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Food Image
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withOpacity(0.2),
                                  Colors.orange.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.orange,
                              size: 28,
                            ),
                          );
                        },
                      )
                      : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.2),
                              Colors.orange.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if ((item['isAddOn'] ?? false) && priceNum == 0) ...[
                  Row(
                    children: [
                      Text(
                        'Rp ${_formatPrice(item['originalPrice'] ?? 0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FREE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Rp ${_formatPrice(priceNum)} x $quantity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item['isAddOn'] ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          else
            Text(
              quantity > 1 ? '($quantity x)' : '',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    final deliveryAddress =
        orderData?['deliveryAddress'] ?? '221B Baker Street, London, UK';
    final driverLat = orderData?['driverLatitude']?.toString() ?? '-';
    final driverLng = orderData?['driverLongitude']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on, color: Colors.red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deliveryAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat: $driverLat, Lng: $driverLng',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.orange,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final subtotalVal =
        (orderData?['subtotal'] is num)
            ? (orderData?['subtotal'] as num).toDouble()
            : null;
    final deliveryFeeVal =
        (orderData?['deliveryFee'] is num)
            ? (orderData?['deliveryFee'] as num).toDouble()
            : null;
    final taxVal =
        (orderData?['tax'] is num)
            ? (orderData?['tax'] as num).toDouble()
            : null;
    final discountVal =
        (orderData?['discount'] is num)
            ? (orderData?['discount'] as num).toDouble()
            : null;
    final totalVal =
        (orderData?['totalPrice'] is num)
            ? (orderData?['totalPrice'] as num).toDouble()
            : null;

    final subtotal = subtotalVal ?? 116000.0;
    final deliveryFee = deliveryFeeVal ?? 5000.0;
    final tax = taxVal ?? 1160.0;
    final discount = discountVal ?? 5000.0;
    final total = totalVal ?? 117160.0;

    final paymentMethod = orderData?['paymentMethod'] ?? 'Cash on Delivery';
    // Keuntungan driver: 30% dari subtotal
    final driverProfit = (subtotal * 0.3).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _buildBreakdownRow('Subtotal', 'Rp ${_formatPrice(subtotal)}'),
          const SizedBox(height: 12),
          _buildBreakdownRow('Delivery Fee', 'Rp ${_formatPrice(deliveryFee)}'),
          const SizedBox(height: 12),
          _buildBreakdownRow('Tax (1%)', 'Rp ${_formatPrice(tax)}'),
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'Discount',
            '- Rp ${_formatPrice(discount)}',
            isDiscount: true,
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow('Payment Method', paymentMethod),
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'Keuntungan Driver (30%)',
            'Rp ${_formatPrice(driverProfit)}',
            isTotal: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[200], thickness: 1, height: 1),
          ),
          _buildBreakdownRow(
            'Total Amount',
            'Rp ${_formatPrice(total)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Poppins',
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Poppins',
            color:
                isDiscount
                    ? Colors.green
                    : (isTotal ? Colors.orange : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How was your experience?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    userRating = index + 1;
                  });
                },
                child: Icon(
                  Icons.star,
                  size: 42,
                  color: index < userRating ? Colors.orange : Colors.grey[200],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your feedback (optional)',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(14),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final status = orderData?['status'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Status: Delivering (belum dikonfirmasi) - Gambar 1
            if (status == 'Delivering' || status == 'Prepared') ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // Update status to Cancelled
                    final orderId = orderData?['id'] ?? orderData?['orderId'];
                    if (orderId != null) {
                      final orderProvider = Provider.of<OrderProvider>(
                        context,
                        listen: false,
                      );
                      await orderProvider.updateOrderStatus(
                        orderId,
                        'Cancelled',
                      );

                      if (mounted) {
                        Navigator.pop(context); // Kembali ke order history
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      (orderData?['deliveredByDriver'] == true)
                          ? () async {
                            // Update status to Completed hanya jika driver sudah menandai selesai
                            final orderId =
                                orderData?['id'] ?? orderData?['orderId'];

                            // STRENGTHENED VALIDATION
                            if (orderId == null || orderId.isEmpty) {
                              print(
                                '❌ [USER COMPLETE] Order ID is null or empty',
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '❌ Order ID tidak valid',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            // Validate deliveredByDriver flag
                            if (orderData?['deliveredByDriver'] != true) {
                              print(
                                '❌ [USER COMPLETE] Order $orderId: deliveredByDriver is false',
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '❌ Driver belum menandai selesai',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            print('🎯 [USER COMPLETE] Order: $orderId');
                            print('User ID: ${orderData?['userId']}');
                            print('Driver ID: ${orderData?['driverId']}');

                            final orderProvider = Provider.of<OrderProvider>(
                              context,
                              listen: false,
                            );
                            await orderProvider.updateOrderStatus(
                              orderId,
                              'Completed',
                            );

                            if (mounted) {
                              setState(() {
                                orderData?['status'] = 'Completed';
                                _showCompletedPattern =
                                    true; // Reset pattern untuk ditampilkan lagi
                              });

                              // Restart timer untuk pattern
                              _patternTimer?.cancel();
                              _patternTimer = null;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Pesanan #${orderId.substring(0, 8)} berhasil diselesaikan!',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                          : null, // Disabled jika driver belum menandai selesai
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (orderData?['deliveredByDriver'] == true)
                            ? AppColors.primaryOrange
                            : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation:
                        (orderData?['deliveredByDriver'] == true) ? 3 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (orderData?['deliveredByDriver'] == true)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      if (orderData?['deliveredByDriver'] == true)
                        const SizedBox(width: 8),
                      Text(
                        (orderData?['deliveredByDriver'] == true)
                            ? 'Track Order - Konfirmasi Selesai'
                            : 'Menunggu Driver',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Status: Completed & belum submit review - Gambar 2
            if (status == 'Completed' && !_hasSubmittedReview) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (userRating > 0) {
                      setState(() {
                        _hasSubmittedReview = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Thank you for your review!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please give a rating',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Submit Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Status: Completed & sudah submit review - Gambar 3
            if (status == 'Completed' && _hasSubmittedReview) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showReorderDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Reorder',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Status: Cancelled
            if (status == 'Cancelled') ...[
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
                      SizedBox(height: 4),
                      Text(
                        'Reason for Cancellation',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Duplicate order',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showReorderDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Reorder',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Reorder Items?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          content: const Text(
            'Do you want to add these items to your cart?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Items added to cart!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatPrice(dynamic price) {
    final intPrice = (price as num).toInt();
    return intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _patternTimer?.cancel();
    _orderListener?.cancel();
    super.dispose();
  }
}
