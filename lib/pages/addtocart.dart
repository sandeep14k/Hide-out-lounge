import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hide_out_lounge/pages/address.dart';
import 'package:hide_out_lounge/pages/bill.dart';
import 'package:hide_out_lounge/widget/widget_support.dart';

class CartPage extends StatefulWidget {
  final String userId;

  const CartPage({required this.userId, super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<QueryDocumentSnapshot>? cartItems;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      if (widget.userId.isEmpty) {
        debugPrint("Error: userId is empty");
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart')
          .get();

      setState(() {
        cartItems = querySnapshot.docs;
      });
    } catch (e) {
      debugPrint("Error fetching cart items: $e");
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
  try {
    if (newQuantity < 1) {
      // If quantity is less than 1, remove the item from the cart
      await removeItem(itemId);
      return;
    }

    // Fetch the item to get the price per unit
    final itemDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart')
        .doc(itemId)
        .get();

    final itemData = itemDoc.data() as Map<String, dynamic>? ?? {};
    // Fetch the Price as a number
final total = int.tryParse(itemData['Total']?.toString() ?? '0') ?? 0;
final quantity = int.tryParse(itemData['Quantity']?.toString() ?? '1') ?? 1; // Avoid division by zero

final pricePerUnit = total ~/ quantity;
print(pricePerUnit);   
    // Ensure this is a number

    // Debug logs
  
    debugPrint("Price per unit: $pricePerUnit");
    debugPrint("New quantity: $newQuantity");

    // Calculate the new total
    final newTotal = pricePerUnit * newQuantity;

    // Debug log for new total
    debugPrint("New total: $newTotal");

    // Update the quantity and total in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart')
        .doc(itemId)
        .update({
      'Quantity': newQuantity,
      'Total': newTotal,
    });

    fetchCartItems();
  } catch (e) {
    debugPrint("Error updating quantity: $e");
  }
}
  Future<void> removeItem(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart')
          .doc(itemId)
          .delete();
      fetchCartItems();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Item removed from cart",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error removing item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 205, 51, 51),
      ),
      body: cartItems == null
          ? const Center(child: CircularProgressIndicator())
          : cartItems!.isEmpty
              ? const Center(
                  child: Text("Your cart is empty.",
                      style: TextStyle(fontSize: 18.0)),
                )
              : ListView.builder(
                  itemCount: cartItems!.length,
                  itemBuilder: (context, index) {
                    final item =
                        cartItems![index].data() as Map<String, dynamic>? ?? {};
                    final imageUrl = item['Image'] ?? '';
                    final name = item['Name'] ?? 'Unknown';
                    final quantity = int.tryParse(item['Quantity'].toString()) ?? 0; // Safely parse to int
                    final total = item['Total'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 80.0,
                                height: 80.0,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style:
                                          AppWidget.semiBoldTextFeildStyle()),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Total: ₹$total",
                                    style: AppWidget.LightTextFeildStyle(),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.red),
                                  onPressed: () {
                                    updateQuantity(
                                        cartItems![index].id, quantity - 1);
                                  },
                                ),
                                Text("$quantity",
                                    style: AppWidget.semiBoldTextFeildStyle()),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.green),
                                  onPressed: () {
                                    updateQuantity(
                                        cartItems![index].id, quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: cartItems != null && cartItems!.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 189, 42, 42),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                onPressed: () async {
                  final selectedAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressSelectionPage(
                        userId: widget.userId,
                        cartItems: cartItems!,
                      ),
                    ),
                  );
                  if (selectedAddress != null) {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BillPage(
                          userId: widget.userId,
                          cartItems: cartItems!,
                          address: selectedAddress,
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins',color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}