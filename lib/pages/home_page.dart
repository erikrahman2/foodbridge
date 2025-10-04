import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/food_card.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String deliveryAddress = "No. 1 Bungo Pasang";

  final List<Map<String, dynamic>> categories = [
    {
      'icon': 'assets/icons/burger.png',
      'name': 'Burger',
      'color': Colors.orange,
    },
    {
      'icon': 'assets/icons/gorengan.png',
      'name': 'Fried',
      'color': Colors.yellow,
    },
    {
      'icon': 'assets/icons/icecream.png',
      'name': 'Ice Cream',
      'color': Colors.blue,
    },
    {'icon': 'assets/icons/jus.png', 'name': 'Drink', 'color': Colors.red},
    {'icon': 'assets/icons/mie.png', 'name': 'Noodles', 'color': Colors.yellow},
    {'icon': 'assets/icons/.png', 'name': 'Bread', 'color': Colors.brown},
    {
      'icon': 'assets/icons/sotocat.png',
      'name': 'Soto',
      'color': Colors.orange,
    },
    {
      'icon': 'assets/icons/nasningcat.png',
      'name': 'Nasi Kuning',
      'color': Colors.yellow,
    },
    {
      'icon': 'assets/icons/nasigoreng.png',
      'name': 'Nasi Goreng',
      'color': Colors.orange,
    },
    {'icon': 'assets/icons/more.png', 'name': 'More', 'color': Colors.grey},
  ];

  final List<Map<String, dynamic>> specialOffers = [
    {
      'title': 'Delicious Burger',
      'rating': 4.9,
      'time': '15 min',
      'image': 'assets/burger1.jpg',
      'price': 25000,
      'discount': 20,
    },
    {
      'title': 'Crispy Chicken',
      'rating': 4.8,
      'time': '20 min',
      'image': 'assets/burger2.jpg',
      'price': 30000,
      'discount': 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Deliver to',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: Colors.black54),
                    Text(
                      'Home',
                      style: TextStyle(
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
                    Text(
                      deliveryAddress,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          ),
        ],
      ),
    );
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
          childAspectRatio: 1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
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
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.fastfood, size: 40);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialOffers() {
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
                onTap: () => Navigator.pushNamed(context, AppRoutes.menuList),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  specialOffers.map((offer) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 10),
                      child: FoodCard(
                        title: offer['title'],
                        rating: offer['rating'],
                        time: offer['time'],
                        price: offer['price'],
                        discount: offer['discount'],
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.mealDetail,
                              arguments: offer,
                            ),
                      ),
                    );
                  }).toList(),
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
    path.lineTo(size.width * 0.45, 0); // 45% dari atas
    path.lineTo(size.width * 0.65, size.height); // 65% dari bawah
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
    path.lineTo(size.width * 0.2, size.height); // Mulai dari 20% kiri bawah
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
      'subtitle': 'Happy Valentine\'s Day',
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
      'type': 'split_layout',
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
            // 🔹 Cek type untuk tentukan style
            if (type == 'gradient_with_image') ...[
              // Background diagonal split
              Positioned.fill(
                child: CustomPaint(
                  painter: _DiagonalSplitPainter(color: color),
                ),
              ),
              Row(
                children: [
                  // Left side text
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
                  // Right side image diagonal
                  Expanded(
                    flex: 4,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 🔹 Full background image (banner ke-2 & ke-3)
              Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
              // Tambahin gradient biar teks kebaca
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              // Text overlay di atas gambar
              Positioned(
                left: 20,
                top: 20,
                right: 20,
                bottom: 20,
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
