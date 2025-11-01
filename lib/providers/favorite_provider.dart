// lib/providers/favorite_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;
  
  FavoriteProvider() {
    _loadFavorites();
  }
  
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoaded => _isLoaded;
  
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedFavorites = prefs.getStringList('favorites');
      if (savedFavorites != null) {
        _favoriteIds.clear();
        _favoriteIds.addAll(savedFavorites);
        if (kDebugMode) {
          print('✅ Loaded ${_favoriteIds.length} favorites from storage');
          if (_favoriteIds.isNotEmpty) {
            print('📋 Favorite IDs: $_favoriteIds');
          }
        }
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      _isLoaded = true;
      if (kDebugMode) {
        print('❌ Error loading favorites: $e');
      }
      notifyListeners();
    }
  }
  
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteIds.toList());
      if (kDebugMode) {
        print('💾 Saved ${_favoriteIds.length} favorites to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving favorites: $e');
      }
    }
  }
  
  bool isFavorite(String foodId) {
    // Removed excessive logging that was called on every widget build
    return _favoriteIds.contains(foodId);
  }
  
  Future<void> toggleFavorite(String foodId) async {
    if (_favoriteIds.contains(foodId)) {
      _favoriteIds.remove(foodId);
      if (kDebugMode) {
        print('❌ Removed from favorites: $foodId');
        print('📋 Current favorites count: ${_favoriteIds.length}');
      }
    } else {
      _favoriteIds.add(foodId);
      if (kDebugMode) {
        print('✅ Added to favorites: $foodId');
        print('📋 Current favorites count: ${_favoriteIds.length}');
      }
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  Future<void> removeFavorite(String foodId) async {
    _favoriteIds.remove(foodId);
    if (kDebugMode) {
      print('🗑️ Removed from favorites: $foodId');
      print('📋 Current favorites count: ${_favoriteIds.length}');
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  Future<void> addFavorite(String foodId) async {
    _favoriteIds.add(foodId);
    if (kDebugMode) {
      print('💖 Added to favorites: $foodId');
      print('📋 Current favorites count: ${_favoriteIds.length}');
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    await _saveFavorites();
    if (kDebugMode) {
      print('🗑️ All favorites cleared');
    }
    notifyListeners();
  }
  
  int get favoritesCount => _favoriteIds.length;
  
  Future<void> refresh() async {
    await _loadFavorites();
  }
}