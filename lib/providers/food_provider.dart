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

      if (kDebugMode) {
        print('🔄 Fetching foods from Firestore...');
      }

      final QuerySnapshot snapshot = await _firestore.collection('food').get();

      if (kDebugMode) {
        print('📦 Total documents fetched: ${snapshot.docs.length}');
      }

      _foods =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Tambahkan document ID
            data['id'] = doc.id;

            // Normalize dan set default values untuk field penting
            data['category'] = (data['category'] ?? '').toString().trim();
            data['title'] = (data['title'] ?? 'Unknown Food').toString();
            data['description'] =
                (data['description'] ?? 'No description available').toString();
            data['time'] = (data['time'] ?? '0 min').toString();
            data['image'] = (data['image'] ?? '').toString();

            // Convert number fields dengan aman
            data['price'] = _toDouble(data['price']);
            data['rating'] = _toDouble(data['rating']);
            data['discount'] = _toInt(data['discount']);

            // Handle ingredients - bisa berupa List atau String
            if (data['ingredients'] != null) {
              if (data['ingredients'] is List) {
                data['ingredients'] = List<String>.from(data['ingredients']);
              } else if (data['ingredients'] is String) {
                // Jika string, biarkan sebagai string (akan di-parse di UI)
                data['ingredients'] = data['ingredients'].toString();
              }
            } else {
              data['ingredients'] = <String>[];
            }

            // Handle tags jika ada
            if (data['tags'] != null) {
              if (data['tags'] is List) {
                data['tags'] = List<String>.from(data['tags']);
              }
            } else {
              data['tags'] = <String>[];
            }

            // Default favorite status
            data['isFavorite'] = data['isFavorite'] ?? false;

            if (kDebugMode) {
              print(
                '🍔 Food loaded: ${data['title']} | Category: ${data['category']} | Price: ${data['price']}',
              );
            }

            return data;
          }).toList();

      _filteredFoods = _foods;

      if (kDebugMode) {
        print('✅ Total foods loaded: ${_foods.length}');
        print('✅ Filtered foods: ${_filteredFoods.length}');

        // Print kategori yang tersedia
        final categories = _foods.map((f) => f['category']).toSet();
        print('📋 Available categories: $categories');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching foods: $e');
      }
      _foods = [];
      _filteredFoods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper untuk convert ke double dengan aman
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Helper untuk convert ke int dengan aman
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// Filter berdasarkan kategori
  void filterByCategory(String category) {
    if (kDebugMode) {
      print('🔍 Filtering by category: $category');
    }

    _selectedCategory = category;

    if (category == 'All') {
      _filteredFoods = _foods;
    } else {
      // Case-insensitive comparison dan trim whitespace
      _filteredFoods =
          _foods.where((food) {
            final foodCategory =
                (food['category'] ?? '').toString().toLowerCase().trim();
            final searchCategory = category.toLowerCase().trim();
            return foodCategory == searchCategory;
          }).toList();
    }

    if (kDebugMode) {
      print('✅ Filtered results: ${_filteredFoods.length} items');
      if (_filteredFoods.isEmpty && category != 'All') {
        print('⚠️ No items found for category: $category');
        print(
          '💡 Available categories: ${_foods.map((f) => f['category']).toSet()}',
        );
      }
    }

    notifyListeners();
  }

  /// Fitur pencarian makanan
  void searchFoods(String query) {
    if (kDebugMode) {
      print('🔍 Searching for: "$query"');
    }

    if (query.isEmpty) {
      // Jika query kosong, kembalikan sesuai kategori yang dipilih
      _filteredFoods =
          _selectedCategory == 'All'
              ? _foods
              : _foods.where((food) {
                final foodCategory =
                    (food['category'] ?? '').toString().toLowerCase().trim();
                final searchCategory = _selectedCategory.toLowerCase().trim();
                return foodCategory == searchCategory;
              }).toList();
    } else {
      // Search berdasarkan title, category, atau description
      final searchQuery = query.toLowerCase().trim();

      _filteredFoods =
          _foods.where((food) {
            final title = (food['title'] ?? '').toString().toLowerCase();
            final category = (food['category'] ?? '').toString().toLowerCase();
            final description =
                (food['description'] ?? '').toString().toLowerCase();

            return title.contains(searchQuery) ||
                category.contains(searchQuery) ||
                description.contains(searchQuery);
          }).toList();
    }

    if (kDebugMode) {
      print('✅ Search results: ${_filteredFoods.length} items');
    }

    notifyListeners();
  }

  /// Ambil detail makanan berdasarkan ID
  Map<String, dynamic>? getFoodById(String id) {
    try {
      return _foods.firstWhere((food) => food['id'] == id);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Food not found with id: $id');
      }
      return null;
    }
  }

  /// Ambil makanan berdasarkan kategori
  List<Map<String, dynamic>> getFoodsByCategory(String category) {
    if (category == 'All') {
      return _foods;
    }

    return _foods.where((food) {
      final foodCategory =
          (food['category'] ?? '').toString().toLowerCase().trim();
      final searchCategory = category.toLowerCase().trim();
      return foodCategory == searchCategory;
    }).toList();
  }

  /// Ambil makanan dengan rating tertinggi
  List<Map<String, dynamic>> getTopRatedFoods({int limit = 5}) {
    final sortedFoods = List<Map<String, dynamic>>.from(_foods);
    sortedFoods.sort(
      (a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0),
    );
    return sortedFoods.take(limit).toList();
  }

  /// Ambil makanan dengan diskon
  List<Map<String, dynamic>> getDiscountedFoods() {
    return _foods.where((food) => (food['discount'] ?? 0) > 0).toList();
  }

  /// Tambah data makanan ke Firestore
  Future<void> addFood(Map<String, dynamic> newFood) async {
    try {
      if (kDebugMode) {
        print('➕ Adding new food: ${newFood['title']}');
      }

      await _firestore.collection('food').add(newFood);
      await fetchFoodsFromFirestore(); // refresh data

      if (kDebugMode) {
        print('✅ Food added successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding food: $e');
      }
      rethrow;
    }
  }

  /// Update data makanan di Firestore
  Future<void> updateFood(String id, Map<String, dynamic> updatedData) async {
    try {
      if (kDebugMode) {
        print('✏️ Updating food: $id');
      }

      await _firestore.collection('food').doc(id).update(updatedData);
      await fetchFoodsFromFirestore(); // refresh data

      if (kDebugMode) {
        print('✅ Food updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating food: $e');
      }
      rethrow;
    }
  }

  /// Hapus data makanan dari Firestore
  Future<void> deleteFood(String id) async {
    try {
      if (kDebugMode) {
        print('🗑️ Deleting food: $id');
      }

      await _firestore.collection('food').doc(id).delete();
      await fetchFoodsFromFirestore(); // refresh data

      if (kDebugMode) {
        print('✅ Food deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting food: $e');
      }
      rethrow;
    }
  }

  /// Toggle favorit di lokal (opsional, bisa sync ke Firestore)
  void toggleFavorite(String id) {
    final index = _foods.indexWhere((food) => food['id'] == id);
    if (index != -1) {
      _foods[index]['isFavorite'] = !(_foods[index]['isFavorite'] ?? false);

      if (kDebugMode) {
        print(
          '❤️ Favorite toggled for: ${_foods[index]['title']} -> ${_foods[index]['isFavorite']}',
        );
      }

      // Juga update di filtered foods jika ada
      final filteredIndex = _filteredFoods.indexWhere(
        (food) => food['id'] == id,
      );
      if (filteredIndex != -1) {
        _filteredFoods[filteredIndex]['isFavorite'] =
            _foods[index]['isFavorite'];
      }

      notifyListeners();
    }
  }

  /// Reset filter dan search
  void resetFilters() {
    _selectedCategory = 'All';
    _filteredFoods = _foods;

    if (kDebugMode) {
      print('🔄 Filters reset');
    }

    notifyListeners();
  }

  /// Get semua kategori unik
  List<String> getCategories() {
    final categories =
        _foods
            .map((food) => (food['category'] ?? '').toString().trim())
            .where((cat) => cat.isNotEmpty)
            .toSet()
            .toList();

    categories.sort();
    return ['All', ...categories];
  }

  /// Refresh data dari Firestore
  Future<void> refresh() async {
    await fetchFoodsFromFirestore();
  }
}
