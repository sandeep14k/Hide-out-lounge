import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hide_out_lounge/pages/addtocart.dart';
import 'package:hide_out_lounge/pages/details.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = false, salad = false, burger = false;
  String category = "All";
  String? name,userId;
  getShareprefname() async{
    try{
     userId = await SharedPreferenceHelper().getUserId();
     name = await SharedPreferenceHelper().getUserName();
    }on Exception catch(e){
      print(e);
      name="gusset";
    }
    setState(() {
      
    });
  }

 @override
  @override
  void initState() {
    super.initState();
    getShareprefname();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40, left: 20, right: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name == null ? "Guest" : "Welcome, $name",
                    style: AppWidget.boldTextStyle(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(userId: userId ?? 'defaultUserId')));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text("Delicious Food", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Discover and Get Great Food",
                  style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.only(right: 20.0),
                child: showItem(),
              ),
              const SizedBox(height: 30.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('foodItems')
                    .where('Category', isEqualTo: category == 'All' ? null : category)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No food items available.");
                  }
                  final foodItems = snapshot.data!.docs;
                  // Separate items by orientation (horizontal and vertical)
                  List<DocumentSnapshot> horizontalItems = [];
                  List<DocumentSnapshot> verticalItems = [];
                  for (var foodItem in foodItems) {
                    final data = foodItem.data() as Map<String, dynamic>;
                    if (data['Orientation'] == 'Recommended (Horizontal)') {
                      horizontalItems.add(foodItem);
                    } else if (data['Orientation'] == 'Other (Vertical)') {
                      verticalItems.add(foodItem);
                    }
                  }

                  return Column(
                    children: [
                      // Horizontal Items
                      if (horizontalItems.isNotEmpty)
                        Container(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: horizontalItems.length,
                            itemBuilder: (context, index) {
                              final data =
                                  horizontalItems[index].data() as Map<String, dynamic>;
                              return buildHorizontalFoodItem(data);
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Vertical Items
                      if (verticalItems.isNotEmpty)
                        Column(
                          children: verticalItems.map((foodItem) {
                            final data = foodItem.data() as Map<String, dynamic>;
                            return buildVerticalFoodItem(data);
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget buildHorizontalFoodItem(Map<String, dynamic> data) {
  return Container(
    margin: const EdgeInsets.only(right: 10.0), // Increased gap between horizontal items
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
MaterialPageRoute(
            builder: (context) => Details(foodName: data['Name']),
          ),        );
      },
      child: Container(
        margin:EdgeInsets.fromLTRB(4, 4, 4, 10) ,
        width: 200,// Increased gap between items
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Image radius applied
                    child: Image.network(
                      data['Image'],
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                 // Increased gap below image
                Center(child: Text(data['Name'], style: AppWidget.semiBoldTextFeildStyle())),
                const SizedBox(height: 5.0),
                Center(child: Text("\₹${data['Price']}", style: AppWidget.semiBoldTextFeildStyle())),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildVerticalFoodItem(Map<String, dynamic> data) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
MaterialPageRoute(
            builder: (context) => Details(foodName: data['Name']),
          ),      );
    },
    child: Container(
      margin: const EdgeInsets.only(right: 10.0, bottom: 20.0), // Increased gap between vertical items
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15), // Image radius applied
                child: Image.network(
                  data['Image'],
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      data['Name'],
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      "\₹${data['Price']}",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCategoryIcon("Ice-cream", "images/ice-cream.png", icecream),
        buildCategoryIcon("Pizza", "images/pizza.png", pizza),
        buildCategoryIcon("Salad", "images/salad.png", salad),
        buildCategoryIcon("Burger", "images/burger.png", burger),
      ],
    );
  }

  Widget buildCategoryIcon(String label, String asset, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          icecream = label == "Ice-cream";
          pizza = label == "Pizza";
          salad = label == "Salad";
          burger = label == "Burger";
          category = label;
        });
      },
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            asset,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
