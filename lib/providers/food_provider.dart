import 'package:flutter/foundation.dart';

class FoodProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _foods = [];
  List<Map<String, dynamic>> _filteredFoods = [];
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> get foods => _filteredFoods;
  String get selectedCategory => _selectedCategory;

  FoodProvider() {
    _initializeFoods();
  }

  void _initializeFoods() {
    _foods = [
      {
        'id': 1,
        'title': 'Classic Burger',
        'category': 'Burger',
        'rating': 4.8,
        'time': '15 min',
        'price': 25000,
        'discount': 20,
        'description':
            'Juicy beef patty with fresh lettuce, tomato, and our special sauce',
        'ingredients': [
          'Beef Patty',
          'Lettuce',
          'Tomato',
          'Cheese',
          'Special Sauce',
        ],
        'image': null,
      },
      {
        'id': 2,
        'title': 'Chicken Taco',
        'category': 'Taco',
        'rating': 4.6,
        'time': '12 min',
        'price': 18000,
        'discount': 15,
        'description': 'Grilled chicken with fresh salsa and guacamole',
        'ingredients': [
          'Grilled Chicken',
          'Salsa',
          'Guacamole',
          'Corn Tortilla',
        ],
        'image': null,
      },
      {
        'id': 3,
        'title': 'Beef Burrito',
        'category': 'Burrito',
        'rating': 4.7,
        'time': '18 min',
        'price': 32000,
        'description':
            'Spicy beef with rice, beans, and cheese wrapped in soft tortilla',
        'ingredients': ['Beef', 'Rice', 'Black Beans', 'Cheese', 'Tortilla'],
        'image': null,
      },
      {
        'id': 4,
        'title': 'Fresh Orange Juice',
        'category': 'Drink',
        'rating': 4.9,
        'time': '5 min',
        'price': 12000,
        'discount': 10,
        'description': 'Freshly squeezed orange juice',
        'ingredients': ['Fresh Orange'],
        'image': null,
      },
      {
        'id': 5,
        'title': 'Margherita Pizza',
        'category': 'Pizza',
        'rating': 4.5,
        'time': '25 min',
        'price': 45000,
        'description': 'Classic pizza with tomato, mozzarella, and basil',
        'ingredients': ['Tomato Sauce', 'Mozzarella', 'Basil', 'Pizza Dough'],
        'image': null,
      },
      {
        'id': 6,
        'title': 'Glazed Donut',
        'category': 'Donut',
        'rating': 4.3,
        'time': '8 min',
        'price': 8000,
        'discount': 25,
        'description': 'Sweet glazed donut with chocolate topping',
        'ingredients': ['Flour', 'Sugar', 'Chocolate', 'Glaze'],
        'image': null,
      },
      {
        'id': 7,
        'title': 'Caesar Salad',
        'category': 'Salad',
        'rating': 4.4,
        'time': '10 min',
        'price': 22000,
        'description':
            'Fresh romaine lettuce with caesar dressing and croutons',
        'ingredients': [
          'Romaine Lettuce',
          'Caesar Dressing',
          'Croutons',
          'Parmesan',
        ],
        'image': null,
      },
      {
        'id': 8,
        'title': 'Ramen Noodles',
        'category': 'Noodles',
        'rating': 4.6,
        'time': '20 min',
        'price': 28000,
        'description': 'Hot and spicy ramen noodles with vegetables',
        'ingredients': ['Ramen Noodles', 'Vegetables', 'Spicy Broth', 'Egg'],
        'image': null,
      },
    ];

    _filteredFoods = _foods;
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'All') {
      _filteredFoods = _foods;
    } else {
      _filteredFoods =
          _foods.where((food) => food['category'] == category).toList();
    }
    notifyListeners();
  }

  void searchFoods(String query) {
    if (query.isEmpty) {
      _filteredFoods =
          _selectedCategory == 'All'
              ? _foods
              : _foods
                  .where((food) => food['category'] == _selectedCategory)
                  .toList();
    } else {
      _filteredFoods =
          _foods
              .where(
                (food) =>
                    food['title'].toLowerCase().contains(query.toLowerCase()) ||
                    food['category'].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    }
    notifyListeners();
  }

  Map<String, dynamic>? getFoodById(int id) {
    try {
      return _foods.firstWhere((food) => food['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
