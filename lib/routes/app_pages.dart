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
    AppRoutes.home: (context) => HomePage(),
    AppRoutes.menuList: (context) => MenuListPage(),
    AppRoutes.mealDetail: (context) => MealDetailPage(),
    AppRoutes.cart: (context) => CartPage(),
    AppRoutes.payment: (context) => PaymentPage(),
    AppRoutes.orderTracking: (context) => OrderTrackingPage(),
    AppRoutes.deliverySuccess: (context) => DeliverySuccessPage(),
    AppRoutes.ordersHistory: (context) => OrdersHistoryPage(),
    AppRoutes.orderDetail: (context) => OrderDetailPage(),
    AppRoutes.notifications: (context) => NotificationsPage(),
    AppRoutes.favorite: (context) => FavoritePage(),
    AppRoutes.helpCenter: (context) => const HelpCenterPage(),
    AppRoutes.profile: (context) => ProfilePage(),
    AppRoutes.locationPicker: (context) => const LocationPickerPage(),
    AppRoutes.sellerDashboard: (context) => const SellerDashboardPage(),
    AppRoutes.sellerFoodForm: (context) => const SellerFoodFormPage(),
    AppRoutes.driverDashboard: (context) => const DriverDashboardPage(),
  };
}
