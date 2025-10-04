import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final int notificationCount;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                [
                  _buildNavItem(
                    context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    index: 0,
                    route: AppRoutes.home,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    index: 1,
                    route: AppRoutes.ordersHistory,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.favorite_outline,
                    activeIcon: Icons.favorite,
                    index: 2,
                    route: null,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.notifications_outlined,
                    activeIcon: Icons.notifications,
                    index: 3,
                    route: AppRoutes.notifications,
                    badge: notificationCount,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    index: 4,
                    route: null,
                    isProfile: true,
                  ),
                ].map((item) => Expanded(child: item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required int index,
    String? route,
    int? badge,
    bool isProfile = false,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (route != null && currentIndex != index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
          } else {
            Navigator.pushNamed(context, route);
          }
        }
      },
      child: Center(
        child: SizedBox(
          height: 70, // tetap tinggi 70
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: isActive ? 60 : 50,
                height: isActive ? 60 : 50,
                transform:
                    isActive
                        ? Matrix4.translationValues(0, -15, 0)
                        : Matrix4.translationValues(0, 0, 0),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isActive)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? Colors.white : Colors.grey.shade400,
                      size: isActive ? 26 : 24,
                    ),
                    if (badge != null && badge > 0)
                      Positioned(
                        right: isActive ? 8 : 12,
                        top: isActive ? 5 : 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              badge > 9 ? '9+' : badge.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
