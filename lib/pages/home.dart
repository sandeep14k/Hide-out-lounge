import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hide_out_lounge/pages/addtocart.dart';
import 'package:hide_out_lounge/pages/details.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
 List<DocumentSnapshot> verticalItems = [];
  DocumentSnapshot? lastVerticalDoc;
  bool isLoadingVertical = false;
  bool hasMoreVertical = true;
  bool tea = false,
      beverages = false,
      soups = false,
      shakesDesserts = false,
      fastFood = false,
      friedSnacks = false,
      maggieRolls = false,
      chineseFriedRice = false,
      all = true;
  String category = "All";

  String? name, userId;

  getShareprefname() async {
    try {
      userId = await SharedPreferenceHelper().getUserId();
      name = await SharedPreferenceHelper().getUserName();
    } on Exception catch (e) {
      print(e);
      name = "Guest";
    }
    setState(() {
      all = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getShareprefname();
    fetchVerticalItems();
  }

  @override
  Future<void> fetchVerticalItems() async {
    if (!hasMoreVertical || isLoadingVertical) return;

    setState(() => isLoadingVertical = true);

    Query query = FirebaseFirestore.instance
        .collection('foodItems')
        .where('Category', isEqualTo: category == 'All' ? null : category)
        .orderBy('Name') // Sort by a field, e.g., name
        .limit(5); // Adjust limit as needed

    if (lastVerticalDoc != null) {
      query = query.startAfterDocument(lastVerticalDoc!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      lastVerticalDoc = querySnapshot.docs.last;
      verticalItems.addAll(querySnapshot.docs);
    } else {
      hasMoreVertical = false;
    }

    setState(() => isLoadingVertical = false);
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: screenHeight * 0.05, left: screenWidth * 0.05, right: screenWidth * 0.05),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(userId: userId ?? 'defaultUserId'),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: userId != null
                            ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('cart')
                                .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          int itemCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 24,
                              ),
                              if (itemCount > 0)
                                Positioned(
                                  top: -12,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 194, 86, 24),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$itemCount',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color.fromARGB(255, 248, 247, 247),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text("Hide Out", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Discover and Get Great Food", style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),
              showItem(),
              const SizedBox(height: 20.0),
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
                      if (horizontalItems.isNotEmpty)
                        Container(
                          height: screenHeight * 0.3,
                          child:Expanded(
  child: ListView.builder(
    itemCount: verticalItems.length + 1, // Extra item for the loader
    itemBuilder: (context, index) {
      if (index == verticalItems.length) {
        // Show a loading indicator when fetching more
        return hasMoreVertical
            ? Center(child: CircularProgressIndicator())
            : SizedBox.shrink();
      }
      final data = verticalItems[index].data() as Map<String, dynamic>;
      return buildVerticalFoodItem(data, MediaQuery.of(context).size.width);
    },
    controller: ScrollController()..addListener(() {
      if (isLoadingVertical || !hasMoreVertical) return;
      fetchVerticalItems();
    }),
  ),
),

                        ),
                      const SizedBox(height: 20),
                      if (verticalItems.isNotEmpty)
                        Column(
                          children: verticalItems.map((foodItem) {
                            final data = foodItem.data() as Map<String, dynamic>;
                            return buildVerticalFoodItem(data, screenWidth);
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

  Widget buildHorizontalFoodItem(Map<String, dynamic> data, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(foodName: data['Name']),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(4, 4, 4, 10),
          width: screenWidth * 0.5,
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
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: data['Image'],
                        height: screenWidth * 0.4,
                        width: screenWidth * 0.4,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
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

 Widget buildVerticalFoodItem(Map<String, dynamic> data, double screenWidth) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Details(foodName: data['Name']),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(right: 10.0, bottom: 20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10), // Increased padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: data['Image'],
                  height: screenWidth * 0.3, // Increased height
                  width: screenWidth * 0.24, // Increased width
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: screenWidth * 0.5,
                    child: Text(
                      data['Name'],
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  SizedBox(
                    width: screenWidth * 0.5,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 24, color: Color(0xFF3C2F2F)),
                  const SizedBox(width: 10),
                  const Text(
                    "Search",
                    style: TextStyle(fontSize: 18, color: Color(0xFF3C2F2F)),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.filter_list, color: Colors.white, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Row(
              children: [
                buildCategoryButton("All", all),
                buildCategoryButton("Tea & Coffee", tea),
                buildCategoryButton("Beverages", beverages),
                buildCategoryButton("Soups", soups),
                buildCategoryButton("Shakes & Desserts", shakesDesserts),
                buildCategoryButton("Fast Food", fastFood),
                buildCategoryButton("Fried  & Snacks", friedSnacks),
                buildCategoryButton("Maggie & Rolls", maggieRolls),
                buildCategoryButton("Chinese & Fried Rice", chineseFriedRice),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCategoryButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          all = label == "All";
          tea = label == "Tea & Coffee";
          beverages = label == "Beverages";
          soups = label == "Soups";
          shakesDesserts = label == "Shakes & Desserts";
          fastFood = label == "Fast Food";
          friedSnacks = label == "Fried  & Snacks";
          maggieRolls = label == "Maggie & Rolls";
          chineseFriedRice = label == "Chinese & Fried Rice";
          category = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10.0, left: 10, top: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : const Color.fromARGB(255, 228, 229, 229),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 193, 189, 189).withOpacity(.8),
                    blurRadius: 5,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6A6A6A),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}