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
        initialRoute: AppRoutes.home,
        routes: AppPages.routes,
        onGenerateRoute: (settings) {
          // Handle routes that need arguments
          if (settings.name == AppRoutes.driverRegistration ||
              settings.name == AppRoutes.sellerRegistration) {
            return MaterialPageRoute(
              builder: (context) {
                if (settings.name == AppRoutes.driverRegistration) {
                  return const DriverRegistrationPage();
                } else {
                  return const SellerRegistrationPage();
                }
              },
              settings: settings,
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
