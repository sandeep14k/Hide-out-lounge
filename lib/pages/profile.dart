import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hide_out_lounge/service/Auth.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    selectedImage = File(image!.path);
    setState(() {
      uploadItem();
    });
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("profileImages").child(addId);
      final UploadTask task =
          firebaseStorageRef.putFile(selectedImage!); //error detecting is left

      var downloadUrl = await (await task).ref.getDownloadURL();
      await SharedPreferenceHelper().saveImageUrl(downloadUrl);
      if (mounted) {
        setState(() {
          // Update state if needed
        });
      }
    }
  }

  getthesharedpref() async {
    try {
      profile = await SharedPreferenceHelper().getImageUrl();
      name = await SharedPreferenceHelper().getUserName();
      email = await SharedPreferenceHelper().getUserEmail();
    } catch (e) {
      print("Error fetching shared preferences: $e");
    }
    setState(() {});
  }

  onthisload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  @override
  void initState() {
    super.initState();
    onthisload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name == null && email == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: 45.0, left: 20.0, right: 20.0),
                          height: MediaQuery.of(context).size.height / 4.3,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 199, 41, 41),
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.elliptical(
                                      MediaQuery.of(context).size.width,
                                      105.0))),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 6.5),
                            child: Material(
                              elevation: 10.0,
                              borderRadius: BorderRadius.circular(60),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: selectedImage == null
                                    ? GestureDetector(
                                        onTap: () {
                                          getImage();
                                        },
                                        child: profile == null
                                            ? Image.asset(
                                                "images/boy.jpg",
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                profile!,
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    : Image.file(
                                        selectedImage!,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 70.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name ?? "Name not available",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        elevation: 2.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 10.0,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: const Color.fromARGB(255, 219, 52, 52),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    name!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        elevation: 2.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 10.0,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: const Color.fromARGB(255, 212, 61, 61),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    email!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        elevation: 2.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 10.0,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: const Color.fromARGB(255, 207, 42, 42),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Terms and Condition",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        AuthMethods().deleteuser(context);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 2.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: const Color.fromARGB(255, 208, 42, 42),
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Delete Account",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        AuthMethods().SignOut(context);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 2.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: const Color.fromARGB(255, 212, 25, 25),
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "LogOut",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
