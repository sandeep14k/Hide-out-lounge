import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
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
        backgroundColor: const Color.fromARGB(255, 4, 4, 4),
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
                    final quantity = item['Quantity'] ?? 0;
                    final total = item['Total'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: ListTile(
                        leading: Image.network(
                          imageUrl,
                          width: 60.0,
                          height: 60.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(name,
                            style: AppWidget.semiBoldTextFeildStyle()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quantity: $quantity",
                              style: AppWidget.LightTextFeildStyle(),
                            ),
                            Text(
                              "Total: ₹$total",
                              style: AppWidget.LightTextFeildStyle(),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(cartItems![index].id),
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
                  backgroundColor: Colors.black,
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
                  style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
                ),
              ),
            )
          : null,
    );
  }
}
