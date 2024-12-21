import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hide_out_lounge/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> deleteuser(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        user.delete();
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Signup()));
    } catch (e) {}
  }

  Future<void> SignOut(BuildContext context) async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('idToken'); // Remove token from storage
      await prefs.remove('userEmail');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Signup()));
    } catch (e) {}
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idToken = prefs.getString('idToken');
    return idToken != null;
  }
}
