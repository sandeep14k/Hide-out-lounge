import 'package:flutter/material.dart';
import 'package:hide_out_lounge/pages/home.dart';
import 'package:hide_out_lounge/pages/login.dart';
import 'package:hide_out_lounge/pages/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hide_out_lounge/service/Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hide Out',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _checkAppState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator
          }

          if (snapshot.data == 'onboarding') {
            return Onboard();
          } else if (snapshot.data == 'login') {
            return Login();
          } else {
            return Home();
          }
        },
      ),
    );
  }
}

/// Check app state: Onboarding, Login, or Home
Future<String> _checkAppState() async {
  final prefs = await SharedPreferences.getInstance();
  final bool? onboardingComplete = prefs.getBool('onboardingComplete');
  final bool loggedIn = await AuthMethods().isLoggedIn();

  if (onboardingComplete == null || !onboardingComplete) {
    return 'onboarding';
  } else if (loggedIn) {
    return 'home';
  } else {
    return 'login';
  }
}
