import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For image caching
import 'package:hide_out_lounge/pages/addtocart.dart';
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
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    fetchFoodDetails();
    fetchUserId();
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

    setState(() {
      isAddingToCart = true;
    });

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(userId: userId ?? 'defaultUserId'),
        ),
      );
    } catch (e) {
      print("Error adding to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to add food to cart",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: foodDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  top: size.height * 0.05,
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Color.fromARGB(255, 161, 28, 28),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: foodDetails!['Image'],
                        width: size.width * 0.9,
                        height: size.height * 0.3,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
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
                              color: const Color.fromARGB(255, 199, 32, 32),
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
                              color: const Color.fromARGB(255, 199, 32, 32),
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
                          onTap: isAddingToCart ? null : addToCart,
                          child: Container(
                            width: size.width * 0.5,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isAddingToCart
                                  ? const Color.fromARGB(255, 164, 30, 30)
                                  : const Color.fromARGB(255, 199, 32, 32),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isAddingToCart)
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                else
                                  const Text(
                                    "Add to cart",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                const SizedBox(width: 30.0),
                                if (!isAddingToCart)
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 238, 99, 99),
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
            ),
    );
  }
}