import 'package:flutter/material.dart';
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
import 'app_routes.dart';
import '../pages/location_picker_page.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
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
  };
}
