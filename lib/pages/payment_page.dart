// lib/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = 'credit_card';
  bool isProcessing = false;
  Map<String, dynamic>? paymentData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (paymentData == null) {
      paymentData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) {
      final cleaned = v.replaceAll('.', '').replaceAll(',', '.');
      final parsed = double.tryParse(cleaned);
      return parsed == null ? 0 : parsed.toInt();
    }
    return 0;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasArguments = paymentData != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: hasArguments ? _buildWithArguments() : _buildWithCartProvider(),
    );
  }

  Widget _buildWithArguments() {
    final items = List<Map<String, dynamic>>.from(paymentData!['items'] ?? []);
    final subtotal = _toInt(paymentData!['subtotal']);
    final deliveryFee = _toInt(paymentData!['deliveryFee']);
    final tax = _toInt(paymentData!['tax']);
    final discount = _toInt(paymentData!['discount']);
    final total = _toInt(paymentData!['total']);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeliveryAddressSection(),
                const SizedBox(height: 20),
                _buildOrderItemsSection(items),
                const SizedBox(height: 20),
                _buildOrderSummarySection(
                  subtotal,
                  deliveryFee,
                  tax,
                  discount,
                  total,
                ),
                const SizedBox(height: 20),
                _buildPaymentMethodsSection(),
                const SizedBox(height: 24),
                _buildPromoCodeSection(),
              ],
            ),
          ),
        ),
        _buildCheckoutButton(total, items),
      ],
    );
  }

  Widget _buildWithCartProvider() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final subtotal = cartProvider.totalPrice.toInt();
        const deliveryFee = 5000;
        final discount = (subtotal * 0.1).toInt(); // 10%
        final tax = ((subtotal - discount) * 0.01).toInt(); // 1%
        final total = subtotal + deliveryFee + tax - discount;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliveryAddressSection(),
                    const SizedBox(height: 20),
                    _buildOrderItemsSection(cartProvider.cartItems),
                    const SizedBox(height: 20),
                    _buildOrderSummarySection(
                      subtotal,
                      deliveryFee,
                      tax,
                      discount,
                      total,
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentMethodsSection(),
                    const SizedBox(height: 24),
                    _buildPromoCodeSection(),
                  ],
                ),
              ),
            ),
            _buildCheckoutButton(total, cartProvider.cartItems),
          ],
        );
      },
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. 1 Bungo Pasang',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Padang, West Sumatra',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.orange,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsSection(List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length} item${items.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder:
                (context, index) =>
                    Divider(color: Colors.grey[100], height: 1, thickness: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final quantity = _toInt(item['quantity'] ?? 1);
              final price = _toInt(item['price']);
              final title = item['title'] ?? item['name'] ?? 'Unknown Item';

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.2),
                            Colors.orange.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_formatPrice(price)} x $quantity',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${_formatPrice(price * quantity)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection(
    int subtotal,
    int deliveryFee,
    int tax,
    int discount,
    int total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', subtotal),
              const SizedBox(height: 12),
              _buildSummaryRow('Delivery Fee', deliveryFee),
              const SizedBox(height: 12),
              _buildSummaryRow('Tax (1%)', tax),
              const SizedBox(height: 12),
              _buildSummaryRow('Discount (10%)', discount, isDiscount: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: Colors.grey[200],
                  thickness: 1,
                  height: 1,
                ),
              ),
              _buildSummaryRow('Total Amount', total, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    int amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Poppins',
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          '${isDiscount ? '- ' : ''}Rp ${_formatPrice(amount)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Poppins',
            color: isDiscount ? Colors.green : (isTotal ? Colors.orange : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodCard(
          'credit_card',
          'Credit Card',
          Icons.credit_card,
          '•••• •••• •••• 4242',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodCard(
          'paypal',
          'PayPal',
          Icons.payment,
          'foodbridge@email.com',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodCard(
          'cash',
          'Cash on Delivery',
          Icons.money,
          'Pay when it arrives',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = selectedPayment == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.orange.withOpacity(0.08) : Colors.white,
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.orange : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected ? Colors.orange : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promo Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.orange, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.orange,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(int total, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isProcessing ? null : () => _processPayment(total, items),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child:
                isProcessing
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 2.5,
                      ),
                    )
                    : Text(
                      'Complete Payment - Rp ${_formatPrice(total)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  void _processPayment(int total, List<Map<String, dynamic>> items) async {
    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final notificationProvider = context.read<NotificationProvider>();
    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();

    final paymentMethodName = _getPaymentMethodName(selectedPayment);

    // Build sanitized items
    final sanitizedItems = <Map<String, dynamic>>[];
    String merchantId = '';
    for (var it in items) {
      final price = _toInt(it['price']);
      final qty = _toInt(it['quantity']);
      final newItem = Map<String, dynamic>.from(it);
      newItem['price'] = price;
      newItem['quantity'] = qty > 0 ? qty : 1;
      sanitizedItems.add(newItem);
      if (merchantId.isEmpty && (it['merchantId'] ?? '') != '') {
        merchantId = it['merchantId'];
      }
    }

    // Calculate values exactly as shown in UI
    final subtotal = sanitizedItems.fold<int>(
      0, 
      (acc, it) => acc + (it['price'] as int) * (it['quantity'] as int)
    );
    final deliveryFee = paymentData != null ? _toInt(paymentData!['deliveryFee']) : 5000;
    final discount = paymentData != null ? _toInt(paymentData!['discount']) : ((subtotal * 0.1).toInt());
    final tax = paymentData != null ? _toInt(paymentData!['tax']) : (((subtotal - discount) * 0.01).toInt());
    final totalCalculated = subtotal + deliveryFee + tax - discount;

    final payload = <String, dynamic>{
      'items': sanitizedItems,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'tax': tax,
      'totalPrice': totalCalculated,
      'paymentMethod': paymentMethodName,
      'deliveryAddress': 'No. 1 Bungo Pasang, Padang, West Sumatra',
      'customerId': 'user_123',
      'merchantId': merchantId,
      'driverId': '',
      'eta': '30 minutes',
      'estimatedDelivery': DateTime.now().add(const Duration(minutes: 30)),
      'status': 'Active',
      'rating': 5.0,
    };

    try {
      final orderId = await orderProvider.createOrder(payload);
      notificationProvider.orderConfirmed(orderId);

      if (paymentData != null) {
        for (var item in sanitizedItems) {
          cartProvider.removeFromCart(item['id']);
        }
      } else {
        cartProvider.clearCart();
      }

      setState(() {
        isProcessing = false;
      });

      Navigator.pushNamed(context, AppRoutes.orderTracking);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Payment successful! Your order is confirmed.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getPaymentMethodName(String paymentCode) {
    switch (paymentCode) {
      case 'credit_card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'cash':
        return 'Cash on Delivery';
      default:
        return 'Unknown Payment Method';
    }
  }
}