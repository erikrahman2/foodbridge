import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/food_card.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../providers/food_provider.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          // Filter makanan yang difavoritkan
          final favoriteFoods =
              foodProvider.foods
                  .where((food) => food['isFavorite'] == true)
                  .toList();

          if (favoriteFoods.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some foods to your favorites!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteFoods.length,
              itemBuilder: (context, index) {
                final food = favoriteFoods[index];
                return FoodCard(
                  title: food['title'] as String,
                  rating: (food['rating'] as num).toDouble(),
                  time: food['time'] as String,
                  price: food['price'] as int,
                  discount: food['discount'] as int? ?? 0,
                  imagePath: food['image'] as String,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.mealDetail,
                        arguments: food,
                      ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return CustomBottomNavigation(
          currentIndex: 2,
          notificationCount: notificationProvider.unreadCount,
        );
      },
    );
  }
}
