import 'package:flutter/material.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:hide_out_lounge/pages/login.dart';
import 'package:hide_out_lounge/pages/onboarding.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:hide_out_lounge/service/Auth.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This handles background messages
  print('Handling a background message: ${message.messageId}');
}  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
 const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Firebase Messaging Setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// Request permission
NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  print('User granted permission');
} else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  print('User granted provisional permission');
} else {
  print('User declined or has not accepted permission');
}


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      _showNotification(
        message.notification?.title ?? 'No Title',
        message.notification?.body ?? 'No Body',
      );
    });
  
  }
  Future<void> _initializeFCM() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;

      // Get the current FCM token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Save or update the token in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
        }, SetOptions(merge: true));
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
        }, SetOptions(merge: true));
      });
    }
  }
 Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel_id', // Channel ID
      'Default Notifications',
      channelDescription: 'This channel is used for general notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
    
  }

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
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          }

          if (snapshot.data == 'onboarding') {
            return const Onboard();
          } else if (snapshot.data == 'login') {
            return const Login();
          } else {
            return const BottomNav();
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
