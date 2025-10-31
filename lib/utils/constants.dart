import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color primaryYellow = Color(0xFFF39C12);
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color primaryPurple = Color(0xFF9B59B6);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadius = 15.0;
  static const double borderRadiusSmall = 8.0;

  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
}

class AppStrings {
  static const String appName = 'FoodBridge';
  static const String deliverTo = 'Deliver to';
  static const String home = 'Home';
  static const String search = 'Search';
  static const String specialOffers = 'Special Offers';
  static const String viewAll = 'View All';
  static const String addToCart = 'Add to Cart';
  static const String buyNow = 'Buy Now';
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'fast food',
      'icon': 'assets/icons/burgercat.png',
      'color': Colors.orange,
    },
    {
      'name': 'Fried',
      'icon': 'assets/icons/friedcat.png',
      'color': Colors.yellow,
    },
    {'name': 'es krim', 'icon': 'assets/icons/iscat.png', 'color': Colors.blue},
    {'name': 'minuman', 'icon': 'assets/icons/juscat.png', 'color': Colors.red},
    {
      'name': 'japanese food',
      'icon': 'assets/icons/mie.png',
      'color': Colors.yellow,
    },
    {'name': 'roti', 'icon': 'assets/icons/roticat.png', 'color': Colors.brown},
    {'name': 'mie', 'icon': 'assets/icons/sotocat.png', 'color': Colors.orange},
    {
      'name': 'Nasi Kuning',
      'icon': 'assets/icons/nasningcat.png',
      'color': Colors.yellow,
    },
    {
      'name': 'aneka ampera',
      'icon': 'assets/icons/nasgorcat.png',
      'color': Colors.orange,
    },
    {'name': 'More', 'icon': 'assets/icons/more.png', 'color': Colors.grey},
  ];

  static const List<Map<String, dynamic>> filterCategories = [
    {'name': 'All', 'icon': '🍽️'},
    {'name': 'Aneka Ampera', 'icon': '🍚'},
    {'name': 'Minuman', 'icon': '☕'},
    {'name': 'Fast Food', 'icon': '🍔'},
    {'name': 'Jus', 'icon': '🥤'},
    {'name': 'Es Krim', 'icon': '🍦'},
    {'name': 'Roti', 'icon': '🍞'},
    {'name': 'Gorengan', 'icon': '🍤'},
    {'name': 'Mie', 'icon': '🍲'},
    {'name': 'Japanese Food', 'icon': '🥟'},
    {'name': 'Fried', 'icon': '🍢'},
    {'name': 'Nasi Kuning', 'icon': '🍛'},
    {'name': 'Nasi Uduk', 'icon': '🍚'},
  ];
}
