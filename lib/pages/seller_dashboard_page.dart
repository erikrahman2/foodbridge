import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/seller_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSellerProducts();
    });
  }

  Future<void> _loadSellerProducts() async {
    final sellerProvider = context.read<SellerProvider>();
    final foodProvider = context.read<FoodProvider>();

    if (sellerProvider.currentSeller != null) {
      await foodProvider.fetchFoodsBySeller(sellerProvider.currentSeller!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.sellerFoodForm).then((_) {
            _loadSellerProducts();
          });
        },
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<SellerProvider>(
                  builder: (context, sellerProvider, child) {
                    return Row(
                      children: [
                        Text(
                          sellerProvider.currentSeller?.storeName ??
                              'Toko Saya',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('|', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 4),
                    Consumer<FoodProvider>(
                      builder: (context, foodProvider, child) {
                        return Text(
                          '${foodProvider.foods.length} Produk',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          isDense: true,
        ),
        onChanged: (value) {
          context.read<FoodProvider>().searchFoods(value);
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryOrange,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Produk'),
          Tab(text: 'Terbaru'),
          Tab(text: 'Terlaris'),
          Tab(text: 'Promo'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildProductList(),
        _buildProductList(sortBy: 'newest'),
        _buildProductList(sortBy: 'bestseller'),
        _buildProductList(sortBy: 'promo'),
      ],
    );
  }

  Widget _buildProductList({String? sortBy}) {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        if (foodProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }

        if (foodProvider.foods.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadSellerProducts,
          color: AppColors.primaryOrange,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: foodProvider.foods.length,
            itemBuilder: (context, index) {
              final food = foodProvider.foods[index];
              return _buildProductCard(food);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  food['image'] != null && food['image'].toString().isNotEmpty
                      ? Image.network(
                        food['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.fastfood,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.fastfood,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          food['category'] ?? 'Uncategorized',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if ((food['discount'] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${food['discount']}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rp ${_formatPrice(food['price'] ?? 0)}',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          const SizedBox(width: 2),
                          Text(
                            '${food['rating'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Menu
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 12),
                          Text('Edit Produk'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy_outlined, size: 18),
                          SizedBox(width: 12),
                          Text('Duplikat'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.sellerFoodForm,
                    arguments: food,
                  ).then((_) {
                    _loadSellerProducts();
                  });
                } else if (value == 'delete') {
                  _showDeleteConfirmation(food);
                } else if (value == 'duplicate') {
                  _duplicateProduct(food);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Belum ada produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk, mulai jualan dengan\nmenambahkan produk pertama!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.sellerFoodForm).then((_) {
                _loadSellerProducts();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Produk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final numPrice =
        price is int ? price : (price is double ? price.toInt() : 0);
    return numPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _duplicateProduct(Map<String, dynamic> food) async {
    final foodProvider = context.read<FoodProvider>();

    final duplicateData = Map<String, dynamic>.from(food);
    duplicateData.remove('id');
    duplicateData['title'] = '${duplicateData['title']} (Copy)';

    await foodProvider.addFood(duplicateData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diduplikasi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSellerProducts();
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Hapus Produk'),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${food['title']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final foodProvider = context.read<FoodProvider>();
                  await foodProvider.deleteFood(food['id']);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produk berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadSellerProducts();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
