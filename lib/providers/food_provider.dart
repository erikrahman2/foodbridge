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
        'isFavorite': false,
        'description':
            'Juicy beef patty with fresh lettuce, tomato, and our special sauce',
        'ingredients': [
          'Beef Patty',
          'Lettuce',
          'Tomato',
          'Cheese',
          'Special Sauce',
        ],
        'image': 'assets/images/burger2.jpg',
      },
      {
        'id': 2,
        'title': 'Bakso lado',
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
        'image': 'assets/images/baso.jpg',
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
        'image': 'assets/images/satepadang.jpg',
      },
      {
        'id': 4,
        'title': 'Fresh Orange Juice',
        'category': 'Jus',
        'rating': 4.9,
        'time': '5 min',
        'price': 12000,
        'discount': 10,
        'description': 'Freshly squeezed orange juice',
        'ingredients': ['Fresh Orange'],
        'image': 'assets/images/jusbuah.jpg',
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
        'image': 'assets/images/ph1.jpg',
      },
      {
        'id': 6,
        'title': 'roti pasir putih',
        'category': 'Donat',
        'rating': 4.3,
        'time': '8 min',
        'price': 8000,
        'discount': 25,
        'description': 'Sweet glazed donut with chocolate topping',
        'ingredients': ['Flour', 'Sugar', 'Chocolate', 'Glaze'],
        'image': 'assets/images/roti2.jpg',
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
        'image': 'assets/images/pecellele.jpg',
      },
      {
        'id': 8,
        'title': 'Ramen Noodles',
        'category': 'Mie',
        'rating': 4.6,
        'time': '20 min',
        'price': 28000,
        'description': 'Hot and spicy ramen noodles with vegetables',
        'ingredients': ['Ramen Noodles', 'Vegetables', 'Spicy Broth', 'Egg'],
        'image': 'assets/images/mieayam.jpg',
      },
      {
        'id': 9,
        'title': 'Nasi Goreng Special',
        'category': 'Nasi Goreng',
        'rating': 4.7,
        'time': '20 min',
        'price': 30000,
        'discount': 15,
        'description': 'Fried rice with chicken, egg, and vegetables',
        'ingredients': ['Rice', 'Chicken', 'Egg', 'Vegetables', 'Soy Sauce'],
        'image': 'assets/images/nasigoreng.jpg',
      },
      {
        'id': 10,
        'title': 'Nasi Goreng Seafood',
        'category': 'Nasi Goreng',
        'rating': 4.9,
        'time': '25 min',
        'price': 35000,
        'description': 'Fried rice with fresh seafood and special spices',
        'ingredients': ['Rice', 'Shrimp', 'Squid', 'Fish', 'Spices'],
        'image': 'assets/images/nasigoreng2.jpg',
      },
      {
        'id': 11,
        'title': 'Nasi Kuning',
        'category': 'Nasi Kuning',
        'rating': 4.5,
        'time': '15 min',
        'price': 25000,
        'discount': 10,
        'description': 'Yellow rice with side dishes',
        'ingredients': ['Turmeric Rice', 'Chicken', 'Egg', 'Tempeh', 'Sambal'],
        'image': 'assets/images/nasikuning.jpg',
      },
      {
        'id': 12,
        'title': 'Nasi Kuning Special',
        'category': 'Nasi Kuning',
        'rating': 4.8,
        'time': '18 min',
        'price': 28000,
        'description': 'Yellow rice with premium side dishes',
        'ingredients': ['Turmeric Rice', 'Beef', 'Egg', 'Tofu', 'Cucumber'],
        'image': 'assets/images/nasikuning2.jpg',
      },
      {
        'id': 13,
        'title': 'Nasi Uduk',
        'category': 'Nasi Uduk',
        'rating': 4.6,
        'time': '12 min',
        'price': 22000,
        'discount': 20,
        'description': 'Steamed coconut rice with side dishes',
        'ingredients': ['Coconut Rice', 'Chicken', 'Egg', 'Tempeh', 'Sambal'],
        'image': 'assets/images/nasiuduk.jpg',
      },
      {
        'id': 14,
        'title': 'Nasi Uduk Special',
        'category': 'Nasi Uduk',
        'rating': 4.9,
        'time': '15 min',
        'price': 26000,
        'description': 'Premium steamed coconut rice with fresh ingredients',
        'ingredients': ['Coconut Rice', 'Beef', 'Egg', 'Tofu', 'Cucumber'],
        'image': 'assets/images/nasiuduk2.jpg',
      },
      {
        'id': 15,
        'title': 'Mie Ayam',
        'category': 'Mie',
        'rating': 4.7,
        'time': '15 min',
        'price': 25000,
        'discount': 15,
        'description': 'Chicken noodles with vegetables and special broth',
        'ingredients': ['Noodles', 'Chicken', 'Vegetables', 'Broth', 'Egg'],
        'image': 'assets/images/mie2.jpg',
      },
      {
        'id': 16,
        'title': 'Bakso',
        'category': 'Bakso',
        'rating': 4.5,
        'time': '10 min',
        'price': 20000,
        'description': 'Meatballs soup with noodles and vegetables',
        'ingredients': ['Meatballs', 'Noodles', 'Vegetables', 'Broth'],
        'image': 'assets/images/baso.jpg',
      },
      {
        'id': 17,
        'title': 'Es Kelapa',
        'category': 'Es Krim',
        'rating': 4.8,
        'time': '5 min',
        'price': 15000,
        'discount': 10,
        'description': 'Fresh coconut ice with young coconut',
        'ingredients': ['Young Coconut', 'Ice', 'Sugar'],
        'image': 'assets/images/eskelapa.jpg',
      },
      {
        'id': 18,
        'title': 'Ice Cream Vanilla',
        'category': 'Es Krim',
        'rating': 4.6,
        'time': '3 min',
        'price': 18000,
        'description': 'Creamy vanilla ice cream',
        'ingredients': ['Milk', 'Vanilla', 'Sugar', 'Cream'],
        'image': 'assets/images/eskrim.jpg',
      },
      {
        'id': 19,
        'title': 'Ice Cream Chocolate',
        'category': 'Es Krim',
        'rating': 4.7,
        'time': '3 min',
        'price': 19000,
        'discount': 20,
        'description': 'Rich chocolate ice cream',
        'ingredients': ['Milk', 'Chocolate', 'Sugar', 'Cream'],
        'image': 'assets/images/eskrim2.jpg',
      },
      {
        'id': 20,
        'title': 'Jus Buah Segar',
        'category': 'Jus',
        'rating': 4.9,
        'time': '5 min',
        'price': 14000,
        'description': 'Fresh fruit juice mix',
        'ingredients': ['Orange', 'Apple', 'Pineapple', 'Lemon'],
        'image': 'assets/images/jusbuah.jpg',
      },
      {
        'id': 21,
        'title': 'Jus Sehat',
        'category': 'Jus',
        'rating': 4.8,
        'time': '7 min',
        'price': 16000,
        'discount': 15,
        'description': 'Healthy green juice with vegetables',
        'ingredients': ['Spinach', 'Apple', 'Carrot', 'Ginger'],
        'image': 'assets/images/jussehat.jpg',
      },
      {
        'id': 22,
        'title': 'Kopi Hitam',
        'category': 'Minuman',
        'rating': 4.5,
        'time': '5 min',
        'price': 10000,
        'description': 'Strong black coffee',
        'ingredients': ['Coffee Beans', 'Hot Water'],
        'image': 'assets/images/kopi.jpg',
      },
      {
        'id': 23,
        'title': 'Matcha Latte',
        'category': 'Minuman',
        'rating': 4.7,
        'time': '8 min',
        'price': 20000,
        'discount': 10,
        'description': 'Green tea latte with milk',
        'ingredients': ['Matcha Powder', 'Milk', 'Sugar'],
        'image': 'assets/images/mathcajus.jpg',
      },
      {
        'id': 24,
        'title': 'Pecel Lele',
        'category': 'Pecel Lele',
        'rating': 4.6,
        'time': '15 min',
        'price': 23000,
        'description': 'Fried catfish with rice and sambal',
        'ingredients': ['Catfish', 'Rice', 'Vegetables', 'Sambal'],
        'image': 'assets/images/pecellele.jpg',
      },
      {
        'id': 25,
        'title': 'Roti Bakar',
        'category': 'Roti',
        'rating': 4.4,
        'time': '10 min',
        'price': 15000,
        'discount': 25,
        'description': 'Toasted bread with butter and cheese',
        'ingredients': ['Bread', 'Butter', 'Cheese', 'Jam'],
        'image': 'assets/images/roti\'i.jpg',
      },
      {
        'id': 26,
        'title': 'Roti Tawar',
        'category': 'Roti',
        'rating': 4.3,
        'time': '5 min',
        'price': 12000,
        'description': 'Fresh white bread',
        'ingredients': ['Flour', 'Yeast', 'Milk', 'Butter'],
        'image': 'assets/images/roti2.jpg',
      },
      {
        'id': 27,
        'title': 'Sate Padang',
        'category': 'Sate',
        'rating': 4.8,
        'time': '20 min',
        'price': 35000,
        'description': 'Padang style beef satay with rice',
        'ingredients': ['Beef', 'Rice', 'Spices', 'Coconut Milk'],
        'image': 'assets/images/satepadang.jpg',
      },
      {
        'id': 28,
        'title': 'Soto Ayam',
        'category': 'Soto',
        'rating': 4.7,
        'time': '18 min',
        'price': 28000,
        'discount': 15,
        'description': 'Chicken soup with noodles and vegetables',
        'ingredients': ['Chicken', 'Noodles', 'Vegetables', 'Broth'],
        'image': 'assets/images/soto.jpg',
      },
      {
        'id': 29,
        'title': 'Soto Betawi',
        'category': 'Soto',
        'rating': 4.9,
        'time': '22 min',
        'price': 32000,
        'description': 'Betawi style beef soup with coconut milk',
        'ingredients': ['Beef', 'Coconut Milk', 'Potatoes', 'Tomatoes'],
        'image': 'assets/images/soto2.jpg',
      },
      {
        'id': 30,
        'title': 'Gorengan Campur',
        'category': 'Gorengan',
        'rating': 4.5,
        'time': '8 min',
        'price': 18000,
        'discount': 10,
        'description': 'Mixed fried snacks',
        'ingredients': ['Tempeh', 'Tofu', 'Onion', 'Flour'],
        'image': 'assets/images/gorengan.jpg',
      },
      {
        'id': 31,
        'title': 'Gorengan Premium',
        'category': 'Gorengan',
        'rating': 4.6,
        'time': '10 min',
        'price': 22000,
        'description': 'Premium fried snacks with special batter',
        'ingredients': ['Tempeh', 'Tofu', 'Vegetables', 'Spices'],
        'image': 'assets/images/gorengan2.jpg',
      },
      {
        'id': 32,
        'title': 'Aneka Jus',
        'category': 'Jus',
        'rating': 4.8,
        'time': '6 min',
        'price': 17000,
        'discount': 20,
        'description': 'Variety of fresh fruit juices',
        'ingredients': ['Mixed Fruits', 'Ice', 'Sugar'],
        'image': 'assets/images/anekajus.jpg',
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

  void toggleFavorite(int id) {
    final index = _foods.indexWhere((food) => food['id'] == id);
    if (index != -1) {
      _foods[index]['isFavorite'] = !(_foods[index]['isFavorite'] ?? false);
      notifyListeners();
    }
  }
}
