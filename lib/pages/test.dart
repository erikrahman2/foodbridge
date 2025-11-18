Pages.
C:\Users\Lenovo\foodbridge\lib\pages\home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../pages/location_picker_page.dart';
import '../widgets/food_card.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/page_transition_wrapper.dart';
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

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";
  bool _isScrolled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onScroll() {
    // Deteksi scroll untuk mengubah layout
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: PageTransitionWrapper(
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildPromoBanner()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickySearchDelegate(
                      minHeight: 80,
                      maxHeight: 80,
                      child: Container(
                        color: AppColors.backgroundLight,
                        child: _buildSearchBar(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildCategoryGrid()),
                  SliverToBoxAdapter(child: _buildSpecialOffers()),
                ],
              ),
              if (!_isScrolled)
                Positioned(top: 20, right: 20, child: _buildFloatingCart()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFloatingCart() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
          // Cart di kiri saat scroll
          if (_isScrolled)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.cart);
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
            ),
          // Search bar - memanjang saat tidak scroll
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
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        context.read<FoodProvider>().searchFoods(value);
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                        });
                        context.read<FoodProvider>().searchFoods('');
                      },
                      child: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
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
        // Filter berdasarkan search query jika ada
        var foods = foodProvider.foods;

        if (_searchQuery.isNotEmpty) {
          // Jika ada search query, tampilkan hasil search
          foods = foodProvider.foods;
        } else {
          // Jika tidak ada search, tampilkan special offers
          foods =
              foodProvider.foods
                  .where(
                    (food) =>
                        food['discount'] != null &&
                        (food['discount'] as num) > 0,
                  )
                  .toList();
        }

        if (foods.isEmpty) {
          if (_searchQuery.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No food found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final displayOffers = foods.take(15).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Search Results'
                        : 'Special Offers',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_searchQuery.isEmpty)
                    GestureDetector(
                      onTap:
                          () =>
                              Navigator.pushNamed(context, AppRoutes.menuList),
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
                    onTap:
                        () => Navigator.pushNamed(
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Custom SliverPersistentHeaderDelegate untuk sticky search bar
class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickySearchDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickySearchDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
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

C:\Users\Lenovo\foodbridge\lib\pages\intro_screens_page.dart
import 'package:flutter/material.dart';
import 'package:food_bridge/routes/app_routes.dart';

class IntroScreensPage extends StatefulWidget {
  const IntroScreensPage({super.key});

  @override
  State<IntroScreensPage> createState() => _IntroScreensPageState();
}

class _IntroScreensPageState extends State<IntroScreensPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  late AnimationController _loadingController;
  late AnimationController _fadeController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
 
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
 
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
 
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
 
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
 
    _loadingController.forward();
 
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward().then((_) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    if (page == 1) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    } else if (page == 2) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.welcomeSplash);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B4A),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildFirstScreen(),
          _buildSecondScreen(),
          _buildThirdScreen(),
        ],
      ),
    );
  }

  Widget _buildFirstScreen() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B4A),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _loadingAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondScreen() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B4A),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Image.asset(
                    'assets/images/LogoOnboarding.png',
                    width: 180,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const SpeedIcon(),
                  ),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: value,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Nikmati Kelezatan,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Berbagi Kebaikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 1 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 1 ? Colors.white : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThirdScreen() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B4A),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Image.asset(
                    'assets/images/LogoOnboarding.png',
                    width: 180,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const SpeedIcon(),
                  ),
                ),
              ),
              SizedBox(height: 40 * value),
              Opacity(
                opacity: value,
                child: const Text(
                  'FOOD BRIDGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              SizedBox(height: 16 * value),
              Opacity(
                opacity: value,
                child: const Text(
                  'Menghubungkan Rasa & Kepedulian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: value,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Nikmati Kelezatan,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Berbagi Kebaikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 2 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 2 ? Colors.white : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class SpeedIcon extends StatelessWidget {
  const SpeedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 100,
      child: CustomPaint(
        painter: SpeedIconPainter(),
      ),
    );
  }
}

class SpeedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.5),
      size.height * 0.28,
      circlePaint,
    );

    final arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.72, size.height * 0.5),
      radius: size.height * 0.38,
    );
    canvas.drawArc(
      arcRect,
      -2.8,
      2.0,
      false,
      arcPaint,
    );

    final trianglePath = Path();
    trianglePath.moveTo(size.width * 0.05, size.height * 0.5);
    trianglePath.lineTo(size.width * 0.5, size.height * 0.2);
    trianglePath.lineTo(size.width * 0.5, size.height * 0.8);
    trianglePath.close();

    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

C:\Users\Lenovo\foodbridge\lib\pages\onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:food_bridge/routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      image: 'assets/images/Image (2).png',
      title: 'Pilihan Beragam',
      description: 'Lebih dari 400 restoran di seluruh negeri.',
    ),
    OnboardingContent(
      image: 'assets/images/Default_Create_an_image_of_a_small_3D_style_rocket_Has_white_b_2 1.png',
      title: 'Pengiriman Cepat',
      description: 'Terima pesanan dalam 10 menit.',
    ),
    OnboardingContent(
      image: 'assets/images/Image (3).png',
      title: 'Pelacakan Pesanan',
      description: 'Lacak pesanan Anda secara real-time.',
    ),
    OnboardingContent(
      image: 'assets/images/Image (4).png',
      title: '',
      description: 'Promo dan diskon setiap minggu.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(content: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFFF6B35)
                              : const Color(0xFFFFCDB2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Start enjoying'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B35),
                          side: const BorderSide(color: Color(0xFFFF6B35)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Login / Registration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingSlide({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            content.image,
            height: 300,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

C:\Users\Lenovo\foodbridge\lib\pages\splash_screen_page.dart
import 'package:flutter/material.dart';
import 'package:food_bridge/routes/app_routes.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/burger2.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Food Bridge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Routes
C:\Users\Lenovo\foodbridge\lib\routes\app_pages.dart
import 'package:flutter/material.dart';
import '../pages/intro_screens_page.dart';
import '../pages/splash_screen_page.dart';
import '../pages/onboarding_page.dart';
import '../pages/home_page.dart';
import '../pages/menu_list_page.dart';
import '../pages/meal_detail_page.dart';
import '../pages/cart_page.dart';
import '../pages/payment_page.dart';
import '../pages/order_tracking_page.dart';
import '../pages/delivery_success_page.dart';
import '../pages/orders_history_page.dart';
import '../pages/order_detail_page.dart';
import '../pages/notifications_page.dart';
import '../pages/favorite_page.dart';
import '../pages/profile_page.dart';
import '../pages/help_center_page.dart';
import '../pages/location_picker_page.dart';
import '../pages/seller_dashboard_page.dart';
import '../pages/seller_food_form_page.dart';
import '../pages/driver_dashboard_page.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const IntroScreensPage(),
    AppRoutes.welcomeSplash: (context) => const SplashScreenPage(),
    AppRoutes.onboarding: (context) => const OnboardingPage(),
    AppRoutes.home: (context) => HomePage(), // PERBAIKAN: Tanpa const
    AppRoutes.menuList: (context) => MenuListPage(), // PERBAIKAN: Tanpa const
    AppRoutes.mealDetail:
        (context) => MealDetailPage(), // PERBAIKAN: Tanpa const
    AppRoutes.cart: (context) => CartPage(), // PERBAIKAN: Tanpa const
    AppRoutes.payment: (context) => PaymentPage(), // PERBAIKAN: Tanpa const
    AppRoutes.orderTracking:
        (context) => OrderTrackingPage(), // PERBAIKAN: Tanpa const
    AppRoutes.deliverySuccess:
        (context) => DeliverySuccessPage(), // PERBAIKAN: Tanpa const
    AppRoutes.ordersHistory:
        (context) => OrdersHistoryPage(), // PERBAIKAN: Tanpa const
    AppRoutes.orderDetail:
        (context) => OrderDetailPage(), // PERBAIKAN: Tanpa const
    AppRoutes.notifications:
        (context) => NotificationsPage(), // PERBAIKAN: Tanpa const
    AppRoutes.favorite: (context) => FavoritePage(),
    AppRoutes.helpCenter: (context) => const HelpCenterPage(),
    AppRoutes.profile: (context) => ProfilePage(),
    AppRoutes.locationPicker: (context) => const LocationPickerPage(),
    AppRoutes.sellerDashboard: (context) => const SellerDashboardPage(),
    AppRoutes.sellerFoodForm: (context) => const SellerFoodFormPage(),
    AppRoutes.driverDashboard: (context) => const DriverDashboardPage(),
    // Note: sellerRegistration and driverRegistration handled by onGenerateRoute
  };
}

C:\Users\Lenovo\foodbridge\lib\routes\app_routes.dart
class AppRoutes {
  // Onboarding pages
  static const String splash = '/';
  static const String welcomeSplash = '/welcome-splash';
  static const String onboarding = '/onboarding';
 
  // Main pages
  static const String home = '/home';
  static const String menuList = '/menu-list';
  static const String mealDetail = '/meal-detail';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String payment = '/payment';

  // Order pages
  static const String orderTracking = '/order-tracking';
  static const String deliverySuccess = '/delivery-success';
  static const String ordersHistory = '/orders-history';
  static const String orderDetail = '/order-detail';

  // User pages
  static const String notifications = '/notifications';
  static const String favorite = '/favorite';
  static const String profile = '/profile';
  static const String helpCenter = '/help-center';

  // New page for location picker
  static const String locationPicker = '/location-picker';

  // Seller pages
  static const String sellerRegistration = '/seller-registration';
  static const String sellerDashboard = '/seller-dashboard';
  static const String sellerFoodForm = '/seller-food-form';

  // Driver pages
  static const String driverRegistration = '/driver-registration';
  static const String driverDashboard = '/driver-dashboard';
}

C:\Users\Lenovo\foodbridge\pubspec.yaml
name: food_bridge
description: "A Flutter food delivery application."

# Prevent accidental publishing to pub.dev
publish_to: "none"

version: 1.0.0+1

environment:
  sdk: ^3.7.2

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.2.0
  cloud_firestore: ^6.0.3
  shared_preferences: ^2.2.0

  # State Management
  provider:
    ^6.1.1

    # Google Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  location: ^5.0.3
  geocoding: ^2.1.1

  # UI Components
  cupertino_icons: ^1.0.8

  # HTTP & API
  http: ^1.1.0

  # Image handling
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  firebase_storage: ^13.0.3

  # Utils
  intl: ^0.18.1
  midtrans_sdk: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1

flutter:
  uses-material-design: true

  # Assets (uncomment when you have actual assets)
  assets:
    #   - assets/images/
    - assets/images/aicream.png
    - assets/images/eskrim.jpg
    - assets/images/ph1.jpg
    - assets/images/mieayam.jpg
    - assets/images/anekajus.jpg
    - assets/images/baso.jpg
    - assets/images/eskelapa.jpg
    - assets/images/jusbuah.jpg
    - assets/images/jussehat.jpg
    - assets/images/kopi.jpg
    - assets/images/mathcajus.jpg
    - assets/images/mieayam.jpg
    - assets/images/nasigoreng.jpg
    - assets/images/nasikuning.jpg
    - assets/images/nasiuduk.jpg
    - assets/images/pecellele.jpg
    - assets/images/roti'i.jpg
    - assets/images/satepadang.jpg
    - assets/images/soto.jpg
    - assets/images/eskrim2.jpg
    - assets/images/roti2.jpg
    - assets/images/nasiuduk2.jpg
    - assets/images/mie2.jpg
    - assets/images/nasikuning2.jpg
    - assets/images/nasigoreng2.jpg
    - assets/images/gorengan.jpg
    - assets/images/soto2.jpg
    - assets/images/burger2.jpg
    - assets/images/gorengan2.jpg
    - assets/images/salad.jpg
    - assets/images/saladb.png
    # update
    - assets/images/bluenoodles.jpg
    - assets/images/bigspa.jpg
    - assets/images/ramena.jpg
    - assets/images/katsu1.jpg
    - assets/images/sushi21.jpg
    - assets/images/sushi22.jpg
    - assets/images/ramentpg.jpg
    - assets/images/sugardonat.jpg
    - assets/images/kitdonut.jpg
    - assets/images/rawdonut.jpg
    - assets/images/cocodonut.jpg
    - assets/images/rnbwdonut.jpg
    - assets/images/croisco.jpg
    - assets/images/sugarbread.jpg
    - assets/images/bobabread.jpg
    - assets/images/sugarbread_2.jpg
    - assets/images/dragonjus.jpg
    - assets/images/strosmo.jpg
    - assets/images/yellowrice2.jpg
    - assets/images/amperaf.jpg
    - assets/images/amperaf_2.jpg
    - assets/images/amperaf_3.jpg
    - assets/images/friedrice.jpg
    - assets/images/amperaf_4.jpg
    - assets/images/friedrice_2.jpg
    - assets/images/Image (2).png
    - assets/images/Image (3).png
    - assets/images/Image (4).png
    - assets/images/Default_Create_an_image_of_a_small_3D_style_rocket_Has_white_b_2 1.png
    - assets/images/LogoOnboarding.png

    #   - assets/icons/
    - assets/icons/friedcat.png
    - assets/icons/burgercat.png
    - assets/icons/nasgorcat.png
    - assets/icons/nasningcat.png
    - assets/icons/sotocat.png
    - assets/icons/roticat.png
    - assets/icons/juscat.png
    - assets/icons/iscat.png
    - assets/icons/iccat.png
    - assets/icons/burger.png
    - assets/icons/bread.png
    - assets/icons/donuts.png
    - assets/icons/icecream.png
    - assets/icons/mie.png
    - assets/icons/salad.png
    - assets/icons/nasigoreng.png
    - assets/icons/gorengan.png
    - assets/icons/jus.png
    - assets/icons/more.png

  # Custom fonts
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-Light.ttf
          weight: 300

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/burgercat.png"


C:\Users\Lenovo\foodbridge\lib\main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/food_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/seller_provider.dart';
import 'providers/driver_provider.dart';
import 'pages/driver_registration_page.dart';
import 'pages/seller_registration_page.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'widgets/page_transition_wrapper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:food_bridge/services/midtrans_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await MidtransService.initMidtrans();
  } catch (e) {
    debugPrint(
      '⚠️ Midtrans initialization failed, continuing without payment features: $e',
    );
  }

  try {
    await FirebaseFirestore.instance.collection('app_test').add({
      'status': 'connected',
      'timestamp': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Firestore connection successful');
  } catch (e) {
    debugPrint('⚠️ Firestore connection failed: $e');
  }

  await requestLocationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => SellerProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: MaterialApp(
        title: 'FoodBridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        routes: AppPages.routes,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.driverRegistration ||
              settings.name == AppRoutes.sellerRegistration) {
            Widget page;
            if (settings.name == AppRoutes.driverRegistration) {
              page = const DriverRegistrationPage();
            } else {
              page = const SellerRegistrationPage();
            }
            return SmoothPageRoute(page: page);
          }
 
          final routeBuilder = AppPages.routes[settings.name];
          if (routeBuilder != null) {
            return SmoothPageRoute(
              page: routeBuilder(settings.arguments as BuildContext),
            );
          }
 
          return null;
        },
      ),
    );
  }
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      print('Location permission denied');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permission denied forever');
    return;
  }

  Position position = await Geolocator.getCurrentPosition();
  print('Lat: ${position.latitude}, Lng: ${position.longitude}');
}
