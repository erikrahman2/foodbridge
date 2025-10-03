import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/menu_list_page.dart';
import '../pages/meal_detail_page.dart';
import '../pages/cart_page.dart';
import '../pages/payment_page.dart';
import '../pages/order_tracking_page.dart';
import '../pages/delivery_success_page.dart';
import '../pages/orders_history_page.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.home: (context) => HomePage(),
    AppRoutes.menuList: (context) => MenuListPage(),
    AppRoutes.mealDetail: (context) => MealDetailPage(),
    AppRoutes.cart: (context) => CartPage(),
    AppRoutes.payment: (context) => PaymentPage(),
    AppRoutes.orderTracking: (context) => OrderTrackingPage(),
    AppRoutes.deliverySuccess: (context) => DeliverySuccessPage(),
    AppRoutes.ordersHistory: (context) => OrdersHistoryPage(),
  };
}
