import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/driver_provider.dart';
import '../providers/order_provider.dart';
import '../utils/constants.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  String _selectedTab = 'available'; // available, in_progress, completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDriver();
    });
  }

  Future<void> _initializeDriver() async {
    // Check driver status first
    final driverProvider = context.read<DriverProvider>();
    final args = ModalRoute.of(context)?.settings.arguments as String?;

    if (driverProvider.currentDriver == null && args != null) {
      await driverProvider.checkDriverStatus(args);
    }

    // Load orders
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadAllOrders();

    // Debug: print orders
    print('📦 Total orders loaded: ${orderProvider.allOrders.length}');
    for (var order in orderProvider.allOrders) {
      print(
        '  Order ${order['id']}: status=${order['status']}, driverId=${order['driverId']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = context.watch<DriverProvider>();
    final driver = driverProvider.currentDriver;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _loadOrders();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data pesanan diperbarui'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          // Status driver toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text(
                  driver?.status == 'available' ? 'Online' : 'Offline',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: driver?.status == 'available',
                  onChanged: (value) async {
                    if (driver != null) {
                      await driverProvider.updateDriverStatus(
                        driver.id,
                        value ? 'available' : 'offline',
                      );
                    }
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDriverInfo(driver),
          _buildTabBar(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(driver) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryOrange,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver?.name ?? 'Driver',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${driver?.vehicleType ?? 'Vehicle'} - ${driver?.vehicleNumber ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab('available', 'Pesanan Baru'),
          _buildTab('in_progress', 'Sedang Diantar'),
          _buildTab('completed', 'Selesai'),
          _buildTab('all', 'Semua'),
        ],
      ),
    );
  }

  Widget _buildTab(String value, String label) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? AppColors.primaryOrange : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryOrange : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }

        // Filter orders based on selected tab
        List<Map<String, dynamic>> filteredOrders;

        if (_selectedTab == 'available') {
          // Pesanan yang statusnya "confirmed", "pending", atau "Delivering" dan belum diambil driver
          filteredOrders =
              orderProvider.allOrders
                  .where(
                    (order) =>
                        (order['status'] == 'confirmed' ||
                            order['status'] == 'pending' ||
                            order['status'] == 'Delivering') &&
                        (order['driverId'] == null || order['driverId'] == ''),
                  )
                  .toList();
        } else if (_selectedTab == 'in_progress') {
          // Pesanan yang diambil driver ini, statusnya "Delivering", dan BELUM ditandai selesai
          final driver = context.read<DriverProvider>().currentDriver;
          filteredOrders =
              orderProvider.allOrders
                  .where(
                    (order) =>
                        order['driverId'] == driver?.id &&
                        order['status'] == 'Delivering' &&
                        order['deliveredByDriver'] != true,
                  ) // Exclude yang sudah ditandai selesai
                  .toList();
        } else if (_selectedTab == 'completed') {
          // Pesanan yang sudah ditandai selesai oleh driver ini (termasuk yang masih Delivering dan yang sudah Completed)
          final driver = context.read<DriverProvider>().currentDriver;
          filteredOrders =
              orderProvider.allOrders
                  .where(
                    (order) =>
                        order['driverId'] == driver?.id &&
                        order['deliveredByDriver'] == true,
                  )
                  .toList();
        } else {
          // Tab "all" - tampilkan semua pesanan
          filteredOrders = orderProvider.allOrders.toList();
        }

        if (filteredOrders.isEmpty) {
          final totalOrders = orderProvider.allOrders.length;
          final driver = context.read<DriverProvider>().currentDriver;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _selectedTab == 'available'
                        ? 'Belum ada pesanan baru'
                        : _selectedTab == 'in_progress'
                        ? 'Belum ada pesanan dalam pengiriman'
                        : _selectedTab == 'completed'
                        ? 'Belum ada pesanan yang sudah diantar'
                        : 'Belum ada pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total pesanan di database: $totalOrders',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  if (_selectedTab == 'available')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pesanan akan muncul jika memiliki:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Status: "pending", "confirmed", atau "Delivering"\n'
                              '• Belum ada driver (driverId kosong)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_selectedTab != 'available')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Driver ID: ${driver?.id ?? "tidak ada"}\n'
                        'Filter: ${_selectedTab == 'in_progress' ? 'status=Delivering' : 'deliveredByDriver=true'}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['items'] as List? ?? [];
    final totalItems = items.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int? ?? 0),
    );
    // Hitung keuntungan driver: 30% dari harga produk (totalAmount atau totalPrice)
    final hargaProduk =
        (order['totalAmount'] ?? order['totalPrice'] ?? 0) as num;
    final driverProfit = (hargaProduk * 0.3).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['id']?.substring(0, 8) ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      order['status'],
                      deliveredByDriver: order['deliveredByDriver'] == true,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(
                      order['status'],
                      deliveredByDriver: order['deliveredByDriver'] == true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Nama makanan
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Item Pesanan:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...items
                        .take(3)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Expanded(
                                  child: Text(
                                    '${item['title'] ?? 'Item'} (${item['quantity']}x)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (items.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '... dan ${items.length - 3} item lainnya',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['deliveryAddress'] ?? 'Alamat tidak tersedia',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$totalItems item', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            // ...total harga dihilangkan sesuai permintaan...
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 20,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                const SizedBox(width: 8),
                Text(
                  'Keuntungan Driver: Rp ${_formatPrice(driverProfit)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 'available')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _acceptOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ambil Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (_selectedTab == 'in_progress')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tandai Sudah Terkirim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (_selectedTab == 'all' &&
                (order['driverId'] == null || order['driverId'] == '') &&
                (order['status'] == 'Delivering' ||
                    order['status'] == 'pending' ||
                    order['status'] == 'confirmed'))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _acceptOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ambil Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status, {bool deliveredByDriver = false}) {
    // Jika sudah ditandai selesai oleh driver, tampilkan hijau muda
    if (deliveredByDriver && status == 'Delivering') {
      return Colors.lightGreen;
    }

    switch (status) {
      case 'pending':
      case 'confirmed':
        return Colors.blue;
      case 'Delivering':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status, {bool deliveredByDriver = false}) {
    // Jika sudah ditandai selesai oleh driver, tampilkan status khusus
    if (deliveredByDriver && status == 'Delivering') {
      return 'Menunggu Konfirmasi';
    }

    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'Delivering':
        return 'Dalam Pengiriman';
      case 'Completed':
        return 'Selesai';
      case 'Cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _acceptOrder(Map<String, dynamic> order) async {
    final driver = context.read<DriverProvider>().currentDriver;
    if (driver == null) return;

    final orderId = order['id'] as String?;
    if (orderId == null || orderId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Order ID tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    print('📦 Accepting order: $orderId');
    print('   Driver: ${driver.id} (${driver.name})');
    print('   Current status: ${order['status']}');

    try {
      // Update order dengan driverId dan status
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId) // Pastikan menggunakan orderId yang benar
          .update({
            'driverId': driver.id,
            'driverName': driver.name,
            'status': 'Delivering',
            'updatedAt': DateTime.now().toIso8601String(),
          });

      print('✅ Order $orderId updated successfully');

      // Kirim notifikasi ke Firestore
      await _sendOrderNotificationToFirestore(
        userId: driver.id,
        title: 'Pesanan sedang diantar',
        message: 'pesanan #${order['id']} sedang dalam perjalanan.',
      );

      // Update driver status ke busy
      await context.read<DriverProvider>().updateDriverStatus(
        driver.id,
        'busy',
      );

      // Reload orders
      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan sedang dalam proses pengantaran. Pastikan Anda berada di lokasi tujuan.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        // Pindah ke tab in_progress
        setState(() {
          _selectedTab = 'in_progress';
        });
      }
    } catch (e) {
      print('❌ Error accepting order $orderId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengambil pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeOrder(Map<String, dynamic> order) async {
    final driver = context.read<DriverProvider>().currentDriver;
    if (driver == null) return;

    final orderId = order['id'] as String?;
    if (orderId == null || orderId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Order ID tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validasi bahwa order ini milik driver yang sedang login
    if (order['driverId'] != driver.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Pesanan ini bukan milik Anda'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    print('🏁 Completing order: $orderId');
    print('   Driver: ${driver.id} (${driver.name})');
    print('   Current status: ${order['status']}');

    try {
      // Tandai bahwa driver sudah menyelesaikan pengiriman
      // Status tetap "Delivering", akan berubah ke "Completed" saat pembeli klik Track Order
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId) // Pastikan menggunakan orderId yang benar
          .update({
            'deliveredByDriver': true,
            'deliveredAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });

      print('✅ Order $orderId marked as delivered');

      // Kirim notifikasi ke Firestore
      await _sendOrderNotificationToFirestore(
        userId: driver.id,
        title: 'konfirmasi pesanan anda',
        message:
            'pesanan #${order['id']} telah selesai diantar. Silakan konfirmasi pesanan Anda.',
      );

      // Kirim notifikasi ke Firestore untuk user (pembeli)
      if (order['userId'] != null) {
        await _sendOrderNotificationToFirestore(
          userId: order['userId'],
          title: 'Pesanan telah selesai diantar',
          message:
              'Pesanan telah selesai diantar. Silakan konfirmasi pesanan Anda.',
        );
      }

      // Update driver status ke available
      await context.read<DriverProvider>().updateDriverStatus(
        driver.id,
        'available',
      );

      // Reload orders
      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan telah selesai diantar. Silakan konfirmasi pesanan Anda.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Pindah ke tab completed
        setState(() {
          _selectedTab = 'completed';
        });
      }
    } catch (e) {
      print('❌ Error completing order $orderId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyelesaikan pengiriman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendOrderNotificationToFirestore({
    required String userId,
    required String title,
    required String message,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
