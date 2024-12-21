import 'package:flutter/material.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:hide_out_lounge/pages/forgot_password.dart';
import 'package:hide_out_lounge/pages/signup.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";

  final _formkey = GlobalKey<FormState>();

  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        // Save user token securely in SharedPreferences
        String idToken = (await user.getIdToken()) ?? '';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('idToken', idToken);
        await prefs.setString('userEmail', user.email!); // Optional
      }
      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          content: Text(
        "LogIn Successfull",
        style: TextStyle(fontSize: 20),
      ))));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseException catch (e) {
      print(e.code);
      if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color.fromARGB(255, 229, 18, 18),
            content: Text("wrong password")));
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
                "We have blocked all requests from your device due to many  wrong attempt try after 10 min")));
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
                                onTap: () {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      email = useremailcontroller.text;
                                      password = userpasswordcontroller.text;
                                    });
                                  }
                                  userLogin();
                                },
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 15, 23, 42),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
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
