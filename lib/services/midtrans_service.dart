import 'dart:ui';

import 'package:midtrans_sdk/midtrans_sdk.dart';

class MidtransService {
  static MidtransSDK? _midtransSDK;

  static Future<void> initMidtrans() async {
    try {
      _midtransSDK = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: "YOUR_CLIENT_KEY", // Replace with actual client key
          merchantBaseUrl: "YOUR_MERCHANT_BASE_URL", // Replace with actual base URL
          colorTheme: ColorTheme(
            colorPrimary: Color(0xFFFF8C00), // Orange theme
            colorPrimaryDark: Color(0xFFFF7000),
            colorSecondary: Color(0xFFFF8C00),
          ),
        ),
      );
      print('✅ Midtrans SDK initialized successfully');
    } catch (e) {
      print('⚠️ Failed to initialize Midtrans SDK: $e');
      rethrow;
    }
  }

  static MidtransSDK? get sdk => _midtransSDK;
}