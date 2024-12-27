import 'package:flutter/material.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:hide_out_lounge/pages/login.dart';
import 'package:hide_out_lounge/pages/onboarding.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:hide_out_lounge/service/Auth.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
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
            return BottomNav();
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
