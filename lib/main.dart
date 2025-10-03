import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'FoodBridge',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
          // Remove custom font family since we don't have the font files
          fontFamily: null,
        ),
        initialRoute: AppRoutes.home,
        routes: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
