import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/category_filter.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? selectedCategory;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final foodProvider = context.read<FoodProvider>();

    if (foodProvider.foods.isEmpty && !foodProvider.isLoading) {
      await foodProvider.fetchFoodsFromFirestore();
    }

    if (!_isInitialized && mounted) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null && args != 'More') {
        setState(() {
          selectedCategory = args;
          _isInitialized = true;
        });
        foodProvider.filterByCategory(args);
      } else {
        setState(() {
          selectedCategory = 'All';
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildStickySearchAndFilter(),
          _buildSliverFoodGrid(),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: false,
      floating: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(selectedCategory ?? 'Menu', style: AppTextStyles.heading3),
      centerTitle: true,
      actions: [
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                ),
                if (cartProvider.totalItems > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        cartProvider.totalItems > 99
                            ? '99+'
                            : cartProvider.totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  SliverPersistentHeader _buildStickySearchAndFilter() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        minHeight: 180,
        maxHeight: 180,
        child: Container(
          color: AppColors.backgroundLight,
          child: Column(
            children: [
              _buildSearchBar(),
              CategoryFilter(
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                  context.read<FoodProvider>().filterByCategory(category);
                },
                selectedCategory: selectedCategory ?? 'All',
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSliverFoodGrid() {
    return SliverToBoxAdapter(child: _buildFoodGrid());
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search food...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                context.read<FoodProvider>().searchFoods(value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<FoodProvider>().searchFoods('');
              },
              child: const Icon(Icons.clear, color: Colors.grey, size: 20),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune, color: Colors.black87, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        if (foodProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (foodProvider.foods.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: foodProvider.foods.length,
          itemBuilder: (context, index) {
            final food = foodProvider.foods[index];
            return FoodCard(
              id: food['id']?.toString() ?? '',
              title: food['title'] ?? 'Unknown',
              rating: (food['rating'] ?? 0).toDouble(),
              time: food['time'] ?? '0 min',
              price: (food['price'] ?? 0).toInt(),
              discount: food['discount'] ?? 0,
              imagePath: food['image'] ?? '',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.mealDetail,
                  arguments: food,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No food found',
            style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Custom SliverPersistentHeaderDelegate untuk sticky header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
