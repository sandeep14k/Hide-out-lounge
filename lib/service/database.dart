import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add user details to the 'users' collection
  Future<void> addUserDetail(Map<String, dynamic> userData, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData);
      print("User added successfully.");
    } catch (e) {
      print("Error adding user: $e");
      throw Exception("Error adding user: $e");
    }
  }

  /// Get user details by userId
  Future<Map<String, dynamic>?> getUserDetailById(String userId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      }
      print("No user found for ID: $userId");
      return null;
    } catch (e) {
      print("Error fetching user details: $e");
      throw Exception("Error fetching user details: $e");
    }
  }

  /// Get user details by email
  Future<Map<String, dynamic>?> getUserDetailByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('Email', isEqualTo: email)
          .get();
      print("Query snapshot: ${querySnapshot.docs}");    

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
      print("No user found with email: $email");
      return null;
    } catch (e) {
      print("Error fetching user details by email: $e");
      throw Exception("Error fetching user details by email: $e");
    }
  }

  /// Fetch food items by category
  Stream<QuerySnapshot> getFoodItemsByCategory(String category) {
    try {
      return _firestore
          .collection('foodItems')
          .where('Category', isEqualTo: category)
          .snapshots();
    } catch (e) {
      print("Error fetching food items: $e");
      throw Exception("Error fetching food items: $e");
    }
  }
}
