import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addUserDetail(
      Map<String, dynamic> userData, String userId) async {
    try {
      // Reference to the 'users' collection in Firestore
      CollectionReference usersCollection = _firestore.collection('users');

      // Adding user details with the provided userId
      await usersCollection.doc(userId).set(userData);

      print("User added successfully.");
    } catch (e) {
      print("Error adding user: $e");
      throw Exception("Error adding user: $e");
    }
  }
}
