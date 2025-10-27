// food_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _foods = [];
  List<Map<String, dynamic>> _filteredFoods = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<Map<String, dynamic>> get foods => _filteredFoods;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  FoodProvider() {
    fetchFoodsFromFirestore();
  }

  /// Mengambil data dari koleksi "food" di Firestore
  Future<void> fetchFoodsFromFirestore() async {
    try {
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot =
          await _firestore.collection('food').get();

    _foods = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Pastikan semua field yang mungkin berupa List dikonversi dengan aman
      data['id'] = doc.id;
      data['category'] = data['category'] ?? '';
      data['title'] = data['title'] ?? '';
      data['description'] = data['description'] ?? '';
      data['price'] = (data['price'] ?? 0).toDouble();
      data['image'] = data['image'] ?? '';
      
      // Jika ada list seperti ingredients/tags/kategori
      if (data['ingredients'] != null) {
        data['ingredients'] = List<String>.from(data['ingredients']);
      }
      if (data['tags'] != null) {
        data['tags'] = List<String>.from(data['tags']);
      }

      return data;
    }).toList();

      _filteredFoods = _foods;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching foods: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter berdasarkan kategori
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

  /// Fitur pencarian makanan
  void searchFoods(String query) {
    if (query.isEmpty) {
      _filteredFoods = _selectedCategory == 'All'
          ? _foods
          : _foods
              .where((food) => food['category'] == _selectedCategory)
              .toList();
    } else {
      _filteredFoods = _foods
          .where(
            (food) =>
                (food['title'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (food['category'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  /// Ambil detail makanan berdasarkan ID
  Map<String, dynamic>? getFoodById(String id) {
    try {
      return _foods.firstWhere((food) => food['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Tambah data makanan ke Firestore
  Future<void> addFood(Map<String, dynamic> newFood) async {
    try {
      await _firestore.collection('food').add(newFood);
      await fetchFoodsFromFirestore(); // refresh data
    } catch (e) {
      if (kDebugMode) {
        print('Error adding food: $e');
      }
    }
  }

  /// Toggle favorit di lokal (opsional)
  void toggleFavorite(String id) {
    final index = _foods.indexWhere((food) => food['id'] == id);
    if (index != -1) {
      _foods[index]['isFavorite'] = !(_foods[index]['isFavorite'] ?? false);
      notifyListeners();
    }
  }
}
