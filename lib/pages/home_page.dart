import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../pages/location_picker_page.dart';
import '../widgets/food_card.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String deliveryAddress = "Select your address";
  String deliveryLabel = "Home";
  double? latitude;
  double? longitude;

  // Variable detail alamat
  String streetNumber = "";
  String streetName = "";
  String city = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildPromoBanner(),
              _buildSearchBar(),
              _buildCategoryGrid(),
              _buildSpecialOffers(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // Navigate ke location picker
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LocationPickerPage(
                          initialPosition:
                              latitude != null && longitude != null
                                  ? LatLng(latitude!, longitude!)
                                  : null,
                          currentAddress:
                              deliveryAddress != "Select your address"
                                  ? deliveryAddress
                                  : null,
                        ),
                  ),
                );

                // Update alamat jika user memilih lokasi
                if (result != null) {
                  setState(() {
                    deliveryAddress = result['address'] ?? 'Selected Location';
                    streetNumber = result['streetNumber'] ?? '';
                    streetName = result['streetName'] ?? '';
                    city = result['city'] ?? '';
                    latitude = result['latitude'];
                    longitude = result['longitude'];
                  });
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Deliver to',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black54,
                        size: 18,
                      ),
                      Text(
                        deliveryLabel,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _getShortAddress(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Shopping bag dengan badge dan navigasi ke cart
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    if (cartProvider.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            cartProvider.totalItems > 99
                                ? '99+'
                                : cartProvider.totalItems.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Method untuk format alamat singkat
  String _getShortAddress() {
    if (deliveryAddress == "Select your address") {
      return "Select your address";
    }

    // Format: "No. X Jl. Nama, Kota"
    List<String> parts = [];

    if (streetNumber.isNotEmpty) {
      parts.add('No. $streetNumber');
    }
    if (streetName.isNotEmpty) {
      // Hapus prefix "Jalan" atau "Jl." jika sudah ada
      String cleanStreetName = streetName
          .replaceFirst(RegExp(r'^Jalan\s+', caseSensitive: false), '')
          .replaceFirst(RegExp(r'^Jl\.?\s+', caseSensitive: false), '');
      parts.add('Jl. $cleanStreetName');
    }

    String streetPart = parts.join(' ');

    if (streetPart.isNotEmpty && city.isNotEmpty) {
      return '$streetPart, $city';
    } else if (city.isNotEmpty) {
      return city;
    } else if (streetPart.isNotEmpty) {
      return streetPart;
    }

    return deliveryAddress;
  }

  Widget _buildPromoBanner() {
    return const _PromoBannerWidget();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    'Search',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: AppCategories.categories.length,
        itemBuilder: (context, index) {
          final category = AppCategories.categories[index];
          final String iconPath = category['icon'] as String;
          final String categoryName = category['name'] as String;

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.menuList,
                arguments: categoryName,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.fastfood, size: 32);
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        final specialOffers =
            foodProvider.foods
                .where(
                  (food) =>
                      food['discount'] != null && (food['discount'] as num) > 0,
                )
                .toList();

        if (specialOffers.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayOffers = specialOffers.take(15).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Special Offers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.pushNamed(context, AppRoutes.menuList),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: displayOffers.length,
                itemBuilder: (context, index) {
                  final offer = displayOffers[index];
                  return FoodCard(
                    id: offer['id'].toString(), // TAMBAHAN: pass ID
                    title: offer['title'] as String,
                    rating: (offer['rating'] as num).toDouble(),
                    time: offer['time'] as String,
                    price: offer['price'] as int,
                    discount: offer['discount'] as int,
                    imagePath: offer['image'] as String,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.mealDetail,
                      arguments: offer,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return CustomBottomNavigation(
          currentIndex: 0,
          notificationCount: notificationProvider.unreadCount,
        );
      },
    );
  }
}

// Custom Painter untuk background diagonal split
class _DiagonalSplitPainter extends CustomPainter {
  final Color color;

  _DiagonalSplitPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [color, color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.45, 0);
    path.lineTo(size.width * 0.65, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Clipper untuk gambar diagonal
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Promo Banner Widget dengan Auto-Scroll
class _PromoBannerWidget extends StatefulWidget {
  const _PromoBannerWidget();

  @override
  State<_PromoBannerWidget> createState() => _PromoBannerWidgetState();
}

class _PromoBannerWidgetState extends State<_PromoBannerWidget> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> banners = [
    {
      'category': 'ICE CREAM DAY',
      'title': 'GET YOUR SWEET\nICE CREAM',
      'subtitle': '40% OFF',
      'color': Color(0xFFFDB863),
      'image': 'assets/images/aicream.png',
      'type': 'gradient_with_image',
    },
    {
      'category': 'COUPLES DEAL',
      'title': 'Double\nhappiness.',
      'subtitle': 'Happy Family Day',
      'color': Colors.black87,
      'image': 'assets/images/mieayam.jpg',
      'type': 'image_background',
    },
    {
      'category': 'GREEN DAY',
      'title': 'UP TO\n60% OFF',
      'subtitle': 'Salad Category',
      'color': Color(0xFF0D9488),
      'image': 'assets/images/saladb.png',
      'type': 'image_background',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildPromoBannerItem(
                banner['category'],
                banner['title'],
                banner['subtitle'],
                banner['color'],
                banner['image'],
                banner['type'],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPromoBannerItem(
    String category,
    String title,
    String subtitle,
    Color color,
    String imagePath,
    String type,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (type == 'gradient_with_image') ...[
              Positioned.fill(
                child: CustomPaint(
                  painter: _DiagonalSplitPainter(color: color),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (type == 'image_background') ...[
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black87,
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.orange[400],
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey[600],
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        banners.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.orange : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
