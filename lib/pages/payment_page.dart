import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_bottom_navigation.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = 'credit_card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final total =
              cartProvider.totalPrice + 5000 + (cartProvider.totalPrice * 0.1);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeliveryAddress(),
                      const SizedBox(height: 20),
                      _buildPaymentMethods(),
                    ],
                  ),
                ),
              ),
              _buildPaymentButton(total, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Address', style: TextStyle(fontSize: 12)),
                Text(
                  'No. 1 Bungo Pasang',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Change')),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentOption('credit_card', 'Credit Card', Icons.credit_card),
          _buildPaymentOption('paypal', 'PayPal', Icons.payment),
          _buildPaymentOption('cash', 'Cash on Delivery', Icons.money),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      trailing: Radio<String>(
        value: value,
        groupValue: selectedPayment,
        onChanged: (String? value) {
          setState(() {
            selectedPayment = value!;
          });
        },
      ),
    );
  }

  Widget _buildPaymentButton(double total, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final notificationProvider = context.read<NotificationProvider>();
            final orderProvider = context.read<OrderProvider>();

            // Create order with callback for notification
            orderProvider.createOrder(cartProvider.cartItems, total, (orderId) {
              // Add notification when order is created
              notificationProvider.orderConfirmed(orderId);
            });

            cartProvider.clearCart();
            Navigator.pushNamed(context, AppRoutes.orderTracking);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Pay Now - Rp ${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
