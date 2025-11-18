import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  void show(
    String message, {
    required BuildContext context,
    Color color = const Color(0xFF2196F3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    // TODO: Replace with Firestore or API logic
    return [];
  }

  // Real-time stream notifikasi user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String userId) {
    // Contoh Firestore
    // Pastikan sudah import 'package:cloud_firestore/cloud_firestore.dart';
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList(),
        );
  }

  Future<void> markAsRead(String notificationId) async {
    // TODO: Replace with Firestore or API logic
  }
}
