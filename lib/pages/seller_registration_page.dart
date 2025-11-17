import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/seller_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class SellerRegistrationPage extends StatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  State<SellerRegistrationPage> createState() => _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final TextEditingController _storeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Sebagai Penjual',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<SellerProvider>(
        builder: (context, sellerProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Icon(
                      Icons.store,
                      size: 80,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Nama Toko',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _storeNameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama toko Anda',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama toko tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  if (sellerProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sellerProvider.errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          sellerProvider.isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  // Ambil userId dari argument yang dikirim
                                  final userId =
                                      ModalRoute.of(context)?.settings.arguments
                                          as String? ??
                                      '';

                                  final success = await sellerProvider
                                      .registerAsSeller(
                                        _storeNameController.text.trim(),
                                        userId,
                                      );

                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Berhasil mendaftar sebagai penjual!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.sellerDashboard,
                                    );
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          sellerProvider.isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }
}
