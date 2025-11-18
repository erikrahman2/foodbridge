import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class DriverProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DriverModel? _currentDriver;
  bool _isLoading = false;

  DriverModel? get currentDriver => _currentDriver;
  bool get isLoading => _isLoading;

  /// Register sebagai driver
  Future<void> registerAsDriver({
    required String userId,
    required String name,
    required String phone,
    required String vehicleType,
    required String vehicleNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final driverData = {
        'userId': userId,
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final docRef = await _firestore.collection('drivers').add(driverData);
      
      driverData['id'] = docRef.id;
      _currentDriver = DriverModel.fromMap(driverData);

      if (kDebugMode) {
        print('✅ Driver registered: ${_currentDriver!.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error registering driver: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cek status driver berdasarkan userId
  Future<bool> checkDriverStatus(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('drivers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        _currentDriver = DriverModel.fromMap(data);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking driver status: $e');
      }
      return false;
    }
  }

  /// Get driver by userId
  Future<DriverModel?> getDriverByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('drivers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return DriverModel.fromMap(data);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting driver: $e');
      }
      return null;
    }
  }

  /// Update driver status
  Future<void> updateDriverStatus(String driverId, String status) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (_currentDriver != null && _currentDriver!.id == driverId) {
        _currentDriver = DriverModel(
          id: _currentDriver!.id,
          userId: _currentDriver!.userId,
          name: _currentDriver!.name,
          phone: _currentDriver!.phone,
          vehicleType: _currentDriver!.vehicleType,
          vehicleNumber: _currentDriver!.vehicleNumber,
          status: status,
          createdAt: _currentDriver!.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      if (kDebugMode) {
        print('✅ Driver status updated: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating driver status: $e');
      }
      rethrow;
    }
  }

  /// Logout driver
  void logout() {
    _currentDriver = null;
    notifyListeners();
  }
}
