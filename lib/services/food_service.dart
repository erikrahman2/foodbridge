import 'package:cloud_firestore/cloud_firestore.dart';

class FoodService {
  final CollectionReference _foodCollection =
      FirebaseFirestore.instance.collection('food');

  // Ambil semua data makanan
  Stream<List<Map<String, dynamic>>> getFoods() {
    return _foodCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Tambah data ke Firestore
  Future<void> addFood(Map<String, dynamic> foodData) async {
    await _foodCollection.add(foodData);
  }

  // Hapus data
  Future<void> deleteFood(String id) async {
    await _foodCollection.doc(id).delete();
  }
}
