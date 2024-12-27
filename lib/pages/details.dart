import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';

class Details extends StatefulWidget {
  final String foodName;

  const Details({required this.foodName, super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Map<String, dynamic>? foodDetails;
  int quantity = 1;
  String? userId;
  getShareprefId() async{
    try{
     userId = await SharedPreferenceHelper().getUserId();
    }on Exception catch(e){
      print(e);
    }
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFoodDetails();
    fetchUserId(); // Fetch user ID from shared preferences
  }

  Future<void> fetchFoodDetails() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('foodItems')
          .where('Name', isEqualTo: widget.foodName)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          foodDetails = querySnapshot.docs.first.data();
        });
      }
    } catch (e) {
      print("Error fetching food details: $e");
    }
  }

  Future<void> fetchUserId() async {
    userId = await SharedPreferenceHelper().getUserId();
    
  }

  Future<void> addToCart() async {
    if (userId == null) return;

    Map<String, dynamic> addFoodToCart = {
      "Name": foodDetails!['Name'],
      "Quantity": quantity.toString(),
      "Total": (quantity * int.parse(foodDetails!['Price'])).toString(),
      "Image": foodDetails!['Image']
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add(addFoodToCart);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Food Added to Cart",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: foodDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                  Image.network(
                    foodDetails!['Image'],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodDetails!['Category'],
                            style: AppWidget.semiBoldTextFeildStyle(),
                          ),
                          Text(
                            foodDetails!['Name'],
                            style: AppWidget.boldTextStyle(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Text(quantity.toString(),
                          style: AppWidget.semiBoldTextFeildStyle()),
                      const SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: () {
                          setState(() => quantity++);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    foodDetails!['Detail'],
                    maxLines: 4,
                    style: AppWidget.LightTextFeildStyle(),
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Price",
                            style: AppWidget.semiBoldTextFeildStyle(),
                          ),
                          Text(
                            "\₹${quantity * int.parse(foodDetails!['Price'])}",
                            style: AppWidget.HeadlineTextFeildStyle(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: addToCart,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                "Add to cart",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 30.0),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
