import 'package:cloud_firestore/cloud_firestore.dart';

class GetRestaurantNameUseCase {
  final FirebaseFirestore _firestore;

  GetRestaurantNameUseCase(this._firestore);

  Future<String> execute(String restaurantId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(restaurantId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['name'] ?? 'Unknown Restaurant';
      }

      return 'Unknown Restaurant';
    } catch (e) {
      print('Error getting restaurant name: $e');
      return 'Unknown Restaurant';
    }
  }
}
