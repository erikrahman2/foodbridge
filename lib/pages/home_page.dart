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
      'icon': 'assets/icons/burgercat.png',
      'name': 'Burger',
      'color': Colors.orange,
    },
    {
      'icon': 'assets/icons/friedcat.png',
      'name': 'Fried',
      'color': Colors.yellow,
    },
    {
      'icon': 'assets/icons/iscat.png',
      'name': 'Ice Cream',
      'color': Colors.blue,
    },
    {'icon': 'assets/icons/juscat.png', 'name': 'Drink', 'color': Colors.red},

    {
      'icon': 'assets/icons/roticat.png',
      'name': 'Bread',
      'color': Colors.brown,
    },
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
      'icon': 'assets/icons/nasgorcat.png',
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
      backgroundColor: AppColors.primaryPink,
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
          Row(
            children:
                specialOffers.map((offer) {
                  return Expanded(
                    child: Container(
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
                    ),
                  );
                }).toList(),
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
      'color': Colors.orange,
      'image': 'assets/images/jussehat.jpg',
    },
    {
      'category': 'COUPON',
      'title': 'Don\'t miss our\nhot offers',
      'subtitle': 'Hope you hungry',
      'color': Colors.black87,
      'image': 'assets/images/ph1.jpg',
    },
    {
      'category': 'GREEN DAY',
      'title': 'UP TO\n60% OFF',
      'subtitle': 'Salad Category',
      'color': Colors.teal,
      'image': 'assets/images/mieayam.jpg',
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
              return _buildPromoBannerItem(
                banners[index]['category'],
                banners[index]['title'],
                banners[index]['subtitle'],
                banners[index]['color'],
                banners[index]['image'],
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
            // Background color
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Content
            Row(
              children: [
                // Left side - Text content
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
                // Gradient separator
                Container(
                  width: 2,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Right side - Image
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
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
