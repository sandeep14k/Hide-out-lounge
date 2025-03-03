import 'package:flutter/material.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:hide_out_lounge/pages/forgot_password.dart';
import 'package:hide_out_lounge/pages/signup.dart';
import 'package:hide_out_lounge/service/database.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}
class _LoginState extends State<Login> {
  bool isLoading = false;

  String email = "", password = "";

  final _formkey = GlobalKey<FormState>();

  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

 userLogin() async {
  try {
    // Sign in the user
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.toLowerCase(), password: password);
    User? user = userCredential.user;
    final fcmToken = await FirebaseMessaging.instance.getToken();

      // Save the token in Firestore
      final userId = userCredential.user?.uid;
      if (userId != null && fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        });
      }
    
    if (user != null) {
      // Save user token securely in SharedPreferences
      String idToken = (await user.getIdToken()) ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('idToken', idToken);
      await prefs.setString('userEmail', user.email!);

      // Fetch user details from the database
      print(user.email);
      Map<String, dynamic>? userInfo = await DatabaseMethods().getUserDetailByEmail(user.email!.toLowerCase());
      print(userInfo);

      if (userInfo != null) {
        // Save user details in SharedPreferences
        await prefs.setString('userName', userInfo['Name']);
        await prefs.setString('userId', userInfo['Id']);
         await SharedPreferenceHelper().saveUserName(userInfo['Name']);
      await SharedPreferenceHelper().saveUserEmail(user.email!);
      await SharedPreferenceHelper().saveUserId(userInfo['Id']);
      } else {
        // If user details are not found, sign out the user
        await FirebaseAuth.instance.signOut();
        await prefs.remove('idToken');
        await prefs.remove('userEmail');
        await prefs.remove('userName');
        await prefs.remove('userId');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "User details not found. Please sign up.",
          style: TextStyle(fontSize: 20),
        )));
        return;

      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "LogIn Successful",
        style: TextStyle(fontSize: 20),
      )));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    }
  } on FirebaseException catch (e) {
    if (e.code == 'invalid-credential') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color.fromARGB(255, 229, 18, 18),
          content: Text("Wrong password")));
    } else if (e.code == 'too-many-requests') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
              "We have blocked all requests from your device due to too many wrong attempts. Try again after 10 minutes.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent, content: Text(e.code)));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust layout for keyboard
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Full screen height
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 15, 23, 42),
                      Color.fromARGB(255, 15, 23, 42),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3),
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Text(""),
              ),
              Container(
                margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        "images/logo.png",
                        width: MediaQuery.of(context).size.width / 3.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Login",
                                style: AppWidget.HeadlineTextFeildStyle(),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              TextFormField(
                                controller: useremailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              TextFormField(
                                controller: userpasswordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                  prefixIcon: Icon(Icons.password_outlined),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPassword(),
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "Forgot Password?",
                                    style: AppWidget.semiBoldTextFeildStyle(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 80.0,
                              ),
                              GestureDetector(
  onTap: () async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        email = useremailcontroller.text;
        password = userpasswordcontroller.text;
      });
      await userLogin(); // Call the userLogin function
      setState(() {
        isLoading = false;
      });
    }
  },
  child: Material(
    elevation: 5.0,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      width: 200,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 15, 23, 42),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                "LOGIN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: 'Poppins1',
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ),
  ),
),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: AppWidget.semiBoldTextFeildStyle(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
