import 'package:flutter/material.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:hide_out_lounge/pages/login.dart';
import 'package:hide_out_lounge/service/database.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "", password = "", name = "";

  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String Id = randomAlphaNumeric(10);
      Map<String, dynamic> addUserInfo = {
        "Name": namecontroller.text,
        "Email": mailcontroller.text,
        "Wallet": "0",
        "Id": Id,
      };
      User? user = userCredential.user;
      if (user != null) {
        // Save user token securely in SharedPreferences
        String idToken = (await user.getIdToken()) ?? '';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('idToken', idToken);
        await prefs.setString('userEmail', user.email!); // Optional
      }
      await DatabaseMethods().addUserDetail(addUserInfo, Id);
      await SharedPreferenceHelper().saveUserName(namecontroller.text);
      await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedPreferenceHelper().saveUserWallet('0');
      await SharedPreferenceHelper().saveUserId(Id);
      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          content: Text(
        "Registered Successfully",
        style: TextStyle(fontSize: 20),
      ))));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Password provided is Weak")));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Acount already exist with this mail")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
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
                      Color.fromARGB(255, 12, 18, 33),
                    ])),
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
                        topRight: Radius.circular(40))),
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
                    )),
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
                            borderRadius: BorderRadius.circular(20)),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                "Sign up",
                                style: AppWidget.HeadlineTextFeildStyle(),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              TextFormField(
                                controller: namecontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: 'Name',
                                    hintStyle:
                                        AppWidget.semiBoldTextFeildStyle(),
                                    prefixIcon: Icon(Icons.person_outlined)),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              TextFormField(
                                controller: mailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter E-mail';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle:
                                        AppWidget.semiBoldTextFeildStyle(),
                                    prefixIcon: Icon(Icons.email_outlined)),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              TextFormField(
                                controller: passwordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle:
                                        AppWidget.semiBoldTextFeildStyle(),
                                    prefixIcon: Icon(Icons.password_outlined)),
                              ),
                              SizedBox(
                                height: 80.0,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      email = mailcontroller.text;
                                      name = namecontroller.text;
                                      password = passwordcontroller.text;
                                    });
                                  }
                                  registration();
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
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                        child: Text(
                                      "SIGN UP",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins1',
                                          fontWeight: FontWeight.bold),
                                    )),
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
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: AppWidget.semiBoldTextFeildStyle(),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
