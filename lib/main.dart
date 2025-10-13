import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/food_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: 'FoodBridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'Poppins', // Sesuaikan dengan font Anda
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.home,
        routes: AppPages.routes,
      ),
    );
  }
}
