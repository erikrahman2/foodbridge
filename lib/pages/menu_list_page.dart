import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
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
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Get category from route arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null && args != 'More') {
        selectedCategory = args;
        context.read<FoodProvider>().filterByCategory(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
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
          Expanded(child: _buildFoodGrid()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(selectedCategory ?? 'Menu', style: AppTextStyles.heading3),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ],
    );
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
              child: const Icon(Icons.clear, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        if (foodProvider.foods.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
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
              title: food['title'],
              rating: food['rating'].toDouble(),
              time: food['time'],
              price: food['price'],
              discount: food['discount'],
              imagePath: food['image'],
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
    super.dispose();
  }
}