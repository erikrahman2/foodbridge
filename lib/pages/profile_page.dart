import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../providers/seller_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/order_provider.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import 'location_picker_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data user
  String userName = 'Foodbridge User';
  String userPhone = '(+62) 822 1457 1111';
  String userEmail = 'Foodbridgenoname@icloud.com';
  String userLanguage = 'Indonesia';
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool soundEnabled = true;
  bool autoUpdateEnabled = false;

  // Status seller dan driver
  bool _isSellerRegistered = false;
  bool _isDriverRegistered = false;
  bool _isCheckingStatus = false;

  // Data lokasi
  String userLocation = 'Pilih lokasi Anda';
  double? userLatitude;
  double? userLongitude;

  // Notification flags
  bool _notifiedConfirmed = false;
  bool _notifiedDelivering = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() => _isCheckingStatus = true);

    try {
      // Check seller status
      final sellerProvider = context.read<SellerProvider>();
      await sellerProvider.checkSellerStatus(userEmail);

      // Check driver status
      final driverProvider = context.read<DriverProvider>();
      await driverProvider.checkDriverStatus(userEmail);

      if (mounted) {
        setState(() {
          _isSellerRegistered = sellerProvider.isSeller;
          _isDriverRegistered = driverProvider.currentDriver != null;
          _isCheckingStatus = false;
        });
      }
    } catch (e) {
      print('Error checking registration status: $e');
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  // Fungsi untuk menampilkan notifikasi pesanan
  void _showOrderNotification(String message, {Color color = Colors.orange}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final latestOrder = orderProvider.currentOrder;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (latestOrder != null) {
        if (latestOrder['status'] == 'confirmed' && !_notifiedConfirmed) {
          _showOrderNotification(
            'Pesanan anda telah dikonfirmasi!',
            color: Colors.blue,
          );
          setState(() {
            _notifiedConfirmed = true;
            _notifiedDelivering = false;
          });
        } else if (latestOrder['status'] == 'Delivering' &&
            !_notifiedDelivering) {
          _showOrderNotification(
            'Pesanan anda sedang diantar!',
            color: Colors.orange,
          );
          setState(() {
            _notifiedDelivering = true;
            _notifiedConfirmed = false;
          });
        }
      }
    });
    // Cek status pesanan dari provider (misal OrderProvider)
    // Contoh: final orderProvider = context.watch<OrderProvider>();
    // final latestOrder = orderProvider.currentOrder;
    // if (latestOrder != null) {
    //   if (latestOrder['status'] == 'confirmed') {
    //     _showOrderNotification('Pesanan anda telah dikonfirmasi!', color: Colors.blue);
    //   } else if (latestOrder['status'] == 'Delivering') {
    //     _showOrderNotification('Pesanan anda sedang diantar!', color: Colors.orange);
    //   }
    // }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildMenuList(),
                    const SizedBox(height: 20),
                    _buildToggleSettings(),
                    const SizedBox(height: 80),
                  ],
                ),
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
              'Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/images/profile.jpg'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ubah foto profil')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            userName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                userPhone,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                userEmail,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: AppColors.primaryOrange, width: 1.5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: InkWell(
              onTap: () => _showLogoutDialog(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: AppColors.primaryOrange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Lokasi Saya',
            subtitle: userLocation,
            onTap: () => _openLocationPicker(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: _isSellerRegistered ? Icons.store : Icons.store_outlined,
            title:
                _isSellerRegistered
                    ? 'Cek Toko Saya'
                    : 'Daftar Sebagai Penjual',
            trailing:
                _isSellerRegistered
                    ? const Icon(Icons.verified, color: Colors.green, size: 20)
                    : null,
            onTap: () => _checkAndNavigateToSeller(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon:
                _isDriverRegistered
                    ? Icons.delivery_dining
                    : Icons.delivery_dining_outlined,
            title:
                _isDriverRegistered
                    ? 'Cek Pesanan Driver'
                    : 'Daftar Sebagai Driver',
            trailing:
                _isDriverRegistered
                    ? const Icon(Icons.verified, color: Colors.green, size: 20)
                    : null,
            onTap: () => _checkAndNavigateToDriver(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.local_offer_outlined,
            title: 'Promo Saya',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Lihat promo Anda')));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Metode Pembayaran',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kelola metode pembayaran')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.message_outlined,
            title: 'Pesan',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Lihat pesan Anda')));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.people_outline,
            title: 'Undang Teman',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bagikan kode referral')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Keamanan',
            onTap: () => _showSecurityDialog(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.helpCenter);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bahasa',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showLanguageDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          userLanguage,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(),
          _buildToggleItem(
            title: 'Pemberitahuan Notifikasi',
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          _buildDivider(),
          _buildToggleItem(
            title: 'Mode Gelap',
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() => darkModeEnabled = value);
            },
          ),
          _buildDivider(),
          _buildToggleItem(
            title: 'Suara',
            value: soundEnabled,
            onChanged: (value) {
              setState(() => soundEnabled = value);
            },
          ),
          _buildDivider(),
          _buildToggleItem(
            title: 'Update Otomatis',
            value: autoUpdateEnabled,
            onChanged: (value) {
              setState(() => autoUpdateEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryOrange, size: 24),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryOrange,
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey[200],
    );
  }

  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Edit $title',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onSave(controller.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$title berhasil diperbarui',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
    );
  }

  void _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationPickerPage(
              initialPosition:
                  userLatitude != null && userLongitude != null
                      ? LatLng(userLatitude!, userLongitude!)
                      : null,
              currentAddress:
                  userLocation != 'Pilih lokasi Anda' ? userLocation : null,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        userLocation = result['address'] ?? 'Lokasi terpilih';
        userLatitude = result['latitude'];
        userLongitude = result['longitude'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lokasi berhasil diperbarui',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
        ),
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Pilih Bahasa',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Indonesia',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  trailing:
                      userLanguage == 'Indonesia'
                          ? const Icon(Icons.check, color: Colors.orange)
                          : null,
                  onTap: () {
                    setState(() => userLanguage = 'Indonesia');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'English',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  trailing:
                      userLanguage == 'English'
                          ? const Icon(Icons.check, color: Colors.orange)
                          : null,
                  onTap: () {
                    setState(() => userLanguage = 'English');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Keamanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: const Text(
                    'Ubah Password',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showChangePasswordDialog();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fingerprint),
                  title: const Text(
                    'Biometric Login',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur belum tersedia')),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Ubah Password',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    labelStyle: const TextStyle(fontFamily: 'Poppins'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    labelStyle: const TextStyle(fontFamily: 'Poppins'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    labelStyle: const TextStyle(fontFamily: 'Poppins'),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newPasswordController.text ==
                      confirmPasswordController.text) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password berhasil diubah',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password tidak cocok',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
    );
  }

  void _checkAndNavigateToSeller() async {
    try {
      print('🔍 Checking seller status...');
      final sellerProvider = context.read<SellerProvider>();

      // Cek status seller dengan userId dummy (nanti bisa diganti dengan auth yang sebenarnya)
      // Untuk sementara kita pakai email user sebagai userId
      print('📧 Using userId: $userEmail');
      await sellerProvider.checkSellerStatus(userEmail);

      print('✅ Is seller: ${sellerProvider.isSeller}');

      if (sellerProvider.isSeller && mounted) {
        // Jika sudah terdaftar sebagai seller, langsung ke dashboard
        print('🏪 Navigating to seller dashboard...');
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.sellerDashboard,
        );
        // Refresh status setelah kembali dari dashboard
        if (result != null || mounted) {
          _checkRegistrationStatus();
        }
      } else if (mounted) {
        // Jika belum terdaftar, ke halaman registrasi
        print('📝 Navigating to seller registration...');
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.sellerRegistration,
          arguments: userEmail, // kirim userId
        );
        // Refresh status setelah registrasi
        if (result != null || mounted) {
          _checkRegistrationStatus();
        }
      }
    } catch (e) {
      print('❌ Error checking seller status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkAndNavigateToDriver() async {
    try {
      print('🔍 Checking driver status...');
      final driverProvider = context.read<DriverProvider>();

      // Cek status driver dengan userId (email)
      print('📧 Using userId: $userEmail');
      await driverProvider.checkDriverStatus(userEmail);

      print('✅ Is driver: ${driverProvider.currentDriver != null}');

      if (driverProvider.currentDriver != null && mounted) {
        // Jika sudah terdaftar sebagai driver, langsung ke dashboard
        print('🚗 Navigating to driver dashboard...');
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.driverDashboard,
          arguments: userEmail, // kirim userId untuk reload jika diperlukan
        );
        // Refresh status setelah kembali dari dashboard
        if (result != null || mounted) {
          _checkRegistrationStatus();
        }
      } else if (mounted) {
        // Jika belum terdaftar, ke halaman registrasi
        print('📝 Navigating to driver registration...');
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.driverRegistration,
          arguments: userEmail, // kirim userId
        );
        // Refresh status setelah registrasi
        if (result != null || mounted) {
          _checkRegistrationStatus();
        }
      }
    } catch (e) {
      print('❌ Error checking driver status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar?',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Berhasil logout',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return CustomBottomNavigation(
          currentIndex: 4,
          notificationCount: notificationProvider.unreadCount,
        );
      },
    );
  }
}
