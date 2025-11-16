import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/food_provider.dart';
import '../providers/seller_provider.dart';
import '../utils/constants.dart';

class SellerFoodFormPage extends StatefulWidget {
  const SellerFoodFormPage({super.key});

  @override
  State<SellerFoodFormPage> createState() => _SellerFoodFormPageState();
}

class _SellerFoodFormPageState extends State<SellerFoodFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  String _selectedCategory = 'fast food';
  bool _isEditMode = false;
  String? _editingFoodId;
  bool _isUploading = false;

  XFile? _selectedImage;
  String? _existingImageUrl;

  final List<String> _categories = [
    'fast food',
    'Fried',
    'es krim',
    'minuman',
    'japanese food',
    'mie',
    'Mie',
    'Nasi Kuning',
    'aneka ampera',
    'roti',
    'jus',
    'nasi goreng',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Cek apakah ini edit mode
    final food =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (food != null && !_isEditMode) {
      _isEditMode = true;
      _editingFoodId = food['id'];
      _titleController.text = food['title'] ?? '';
      _descriptionController.text = food['description'] ?? '';
      _priceController.text = food['price']?.toString() ?? '';
      _timeController.text = food['time'] ?? '';
      _discountController.text = food['discount']?.toString() ?? '0';
      _selectedCategory = food['category'] ?? 'fast food';

      // Handle image URL
      final imageUrl = food['image'] ?? '';
      _existingImageUrl = imageUrl;
      _imageUrlController.text = imageUrl;

      // Handle ingredients
      if (food['ingredients'] != null) {
        if (food['ingredients'] is List) {
          _ingredientsController.text = (food['ingredients'] as List).join(
            ', ',
          );
        } else if (food['ingredients'] is String) {
          _ingredientsController.text = food['ingredients'];
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _existingImageUrl;

    try {
      setState(() {
        _isUploading = true;
      });

      final fileName = 'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'food_images/$fileName',
      );

      // Read image as bytes (works for both web and mobile)
      final bytes = await _selectedImage!.readAsBytes();

      // Upload with putData (better for web CORS)
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
          customMetadata: {
            'uploaded-by': 'seller',
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Gambar berhasil diupload!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload gagal: ${e.code}\n${e.message ?? ""}\nGunakan URL sebagai alternatif',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload gagal: $e\nGunakan URL sebagai alternatif'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildPriceSection(),
            const SizedBox(height: 16),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Produk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upload mungkin gagal di web (CORS). Gunakan URL dari Imgur/Pexels sebagai alternatif',
                    style: TextStyle(fontSize: 11, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child:
                  _selectedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            kIsWeb
                                ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                                : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                      )
                      : (_existingImageUrl != null &&
                              _existingImageUrl!.isNotEmpty) ||
                          (_imageUrlController.text.isNotEmpty)
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrlController.text.isNotEmpty
                              ? _imageUrlController.text
                              : _existingImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Gambar tidak dapat dimuat',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap untuk Upload Foto',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              hintText: 'https://i.imgur.com/example.jpg',
              prefixIcon: const Icon(Icons.link, size: 20),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              isDense: true,
              helperText: '💡 Cara upload: imgur.com/upload → Copy direct link',
              helperStyle: TextStyle(color: Colors.blue[700], fontSize: 11),
            ),
            onChanged: (value) {
              setState(() {
                // Update untuk refresh preview
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Dasar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _titleController,
            label: 'Nama Produk',
            hint: 'Contoh: Pizza Margherita',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama produk tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Deskripsi Produk',
            hint: 'Jelaskan detail produk Anda',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Harga',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _priceController,
                  label: 'Harga Normal',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  prefix: const Text('Rp  '),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga wajib diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harus angka';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _discountController,
                  label: 'Diskon',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  suffix: const Text('%'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Tambahan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _timeController,
            label: 'Waktu Persiapan',
            hint: 'Contoh: 25 min',
            suffix: const Text('menit'),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ingredientsController,
            label: 'Ingredients (Bahan-bahan)',
            hint: 'Contoh: Tepung, Telur, Susu, Gula (pisahkan dengan koma)',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                prefix != null
                    ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: prefix,
                    )
                    : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon:
                suffix != null
                    ? Padding(
                      padding: const EdgeInsets.only(right: 12, left: 8),
                      child: suffix,
                    )
                    : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryOrange,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: prefix != null || suffix != null ? 8 : 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isUploading ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child:
                _isUploading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      _isEditMode ? 'Simpan Perubahan' : 'Tambah Produk',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sellerProvider = context.read<SellerProvider>();
    final foodProvider = context.read<FoodProvider>();

    if (sellerProvider.currentSeller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seller tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? imageUrl;

    // Prioritas: 1. Upload file 2. URL input 3. Existing URL
    if (_selectedImage != null) {
      // Coba upload file terlebih dahulu
      imageUrl = await _uploadImage();
      // Jika upload gagal, fallback ke URL input
      if (imageUrl == null && _imageUrlController.text.isNotEmpty) {
        imageUrl = _imageUrlController.text.trim();
      }
      // Jika masih null, pakai existing URL
      if (imageUrl == null &&
          _existingImageUrl != null &&
          _existingImageUrl!.isNotEmpty) {
        imageUrl = _existingImageUrl;
      }
    } else if (_imageUrlController.text.isNotEmpty) {
      // Jika tidak ada file dipilih, pakai URL input
      imageUrl = _imageUrlController.text.trim();
    } else {
      // Pakai existing URL jika ada
      imageUrl = _existingImageUrl;
    }

    // Validasi minimal harus ada gambar
    if (imageUrl == null || imageUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan upload gambar atau masukkan URL gambar'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Parse ingredients from comma-separated string to list
    List<String> ingredients = [];
    if (_ingredientsController.text.trim().isNotEmpty) {
      ingredients =
          _ingredientsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    }

    final foodData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': int.tryParse(_priceController.text) ?? 0,
      'time':
          _timeController.text.trim().isNotEmpty
              ? _timeController.text.trim()
              : '0 min',
      'category': _selectedCategory,
      'image': imageUrl,
      'discount': int.tryParse(_discountController.text) ?? 0,
      'rating': 4.5,
      'sellerId': sellerProvider.currentSeller!.id,
      'sellerName': sellerProvider.currentSeller!.storeName,
      'ingredients': ingredients,
    };

    try {
      if (_isEditMode && _editingFoodId != null) {
        await foodProvider.updateFood(_editingFoodId!, foodData);
      } else {
        await foodProvider.addFood(foodData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Produk berhasil diperbarui'
                  : 'Produk berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _timeController.dispose();
    _discountController.dispose();
    _imageUrlController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }
}
