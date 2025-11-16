import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';

class SellerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SellerModel? _currentSeller;
  bool _isLoading = false;
  String? _errorMessage;

  SellerModel? get currentSeller => _currentSeller;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSeller => _currentSeller != null;

  // Register sebagai penjual
  Future<bool> registerAsSeller(String storeName, String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Cek apakah user sudah terdaftar sebagai seller
      final existingSeller =
          await _firestore
              .collection('sellers')
              .where('userId', isEqualTo: userId)
              .get();

      if (existingSeller.docs.isNotEmpty) {
        _errorMessage = 'Anda sudah terdaftar sebagai penjual';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Buat seller baru
      final sellerId = _firestore.collection('sellers').doc().id;
      final seller = SellerModel(
        id: sellerId,
        userId: userId,
        storeName: storeName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('sellers').doc(sellerId).set(seller.toMap());

      _currentSeller = seller;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cek apakah user adalah seller
  Future<void> checkSellerStatus(String userId) async {
    try {
      if (userId.isEmpty) return;

      final sellerDocs =
          await _firestore
              .collection('sellers')
              .where('userId', isEqualTo: userId)
              .get();

      if (sellerDocs.docs.isNotEmpty) {
        _currentSeller = SellerModel.fromMap(sellerDocs.docs.first.data());
      } else {
        _currentSeller = null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get seller by userId
  Future<SellerModel?> getSellerByUserId(String userId) async {
    try {
      final sellerDocs =
          await _firestore
              .collection('sellers')
              .where('userId', isEqualTo: userId)
              .get();

      if (sellerDocs.docs.isNotEmpty) {
        return SellerModel.fromMap(sellerDocs.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
