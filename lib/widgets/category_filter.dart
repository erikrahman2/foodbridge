import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryFilter extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const CategoryFilter({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  final List<Map<String, dynamic>> categories = const [
    {'name': 'All', 'icon': '🍽️'},
    {'name': 'Nasi Goreng', 'icon': '🍚'},
    {'name': 'Mie', 'icon': '🍜'},
    {'name': 'Burger', 'icon': '🍔'},
    {'name': 'Jus', 'icon': '🥤'},
    {'name': 'Es Krim', 'icon': '🍦'},
    {'name': 'Roti', 'icon': '🍞'},
    {'name': 'Gorengan', 'icon': '🍤'},
    {'name': 'Soto', 'icon': '🍲'},
    {'name': 'Bakso', 'icon': '🥟'},
    {'name': 'Sate', 'icon': '🍢'},
    {'name': 'Nasi Kuning', 'icon': '🍛'},
    {'name': 'Nasi Uduk', 'icon': '🍚'},
    {'name': 'Pecel Lele', 'icon': '🐟'},
    {'name': 'Minuman', 'icon': '☕'},
    {'name': 'Salad', 'icon': '🥗'},
    {'name': 'Pizza', 'icon': '🍕'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category['name'] == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(category['name']),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryOrange : Colors.grey[300]!,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category['icon'], style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
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
}
