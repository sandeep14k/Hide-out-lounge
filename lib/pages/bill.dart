import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BillPage extends StatefulWidget {
  final String userId;
  final List<DocumentSnapshot> cartItems;
  final String address;

  const BillPage({
    required this.userId,
    required this.cartItems,
    required this.address,
    super.key,
  });

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  double get totalAmount {
    return widget.cartItems.fold(
      0.0,
      (previousValue, item) {
        double itemTotal = double.tryParse(item['Total'].toString()) ?? 0.0;
        return previousValue + itemTotal;
      },
    );
  }

  Future<void> _placeOrder({bool isCod = false}) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set({
      'userId': widget.userId,
      'cartItems': widget.cartItems.map((item) => item.data()).toList(),
      'address': widget.address,
      'totalAmount': totalAmount,
      'paymentStatus': isCod ? 'COD' : 'SUCCESS',
      'orderStatus': 'Pending',
      'orderDate': Timestamp.now(),
    });
  }

  Future<void> _clearCart() async {
    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart');
    final cartItemsSnapshot = await cartCollection.get();
    for (var doc in cartItemsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _startPayment() async {
    const String baseUrl = "https://api.phonepe.com/apis/pg/v1/pay";
    const String merchantId = "MERCHANT_ID"; // Replace with your Merchant ID
    const String merchantKey = "MERCHANT_KEY"; // Replace with your Merchant Key

    final String transactionId = "txn_${DateTime.now().millisecondsSinceEpoch}";

    final Map<String, dynamic> payload = {
      "merchantId": merchantId,
      "transactionId": transactionId,
      "amount": (totalAmount * 100).toInt(), // Amount in paise
      "merchantUserId": widget.userId,
      "redirectUrl": "https://your_redirect_url.com", // Add your redirect URL
      "callbackUrl": "https://your_callback_url.com", // Add your callback URL
      "paymentInstrument": {
        "type": "PAY_PAGE",
      }
    };

    final String requestData = json.encode(payload);

    // Generate signature
    final String signature = base64Encode(utf8.encode("$requestData$merchantKey"));

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "X-VERIFY": "$signature###${DateTime.now().millisecondsSinceEpoch}",
        },
        body: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String paymentUrl = responseData['data']['instrumentResponse']['redirectUrl'];

        // Open payment URL in a webview or external browser
        // You can use the `url_launcher` package to open the payment URL
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Summary",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Address:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(widget.address, style: const TextStyle(fontSize: 16.0)),
            const Divider(height: 30),
            const Text(
              "Cart Items:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    leading: Image.network(
                      item['Image'],
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['Name']),
                    subtitle: Text("Quantity: ${item['Quantity']}"),
                    trailing: Text("\₹${item['Total']}"),
                  );
                },
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount:",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\₹$totalAmount",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Payment Method:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: _startPayment, // Call PhonePe payment method
                    child: const Text("Pay with PhonePe"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      await _placeOrder(isCod: true); // Place the order with payment status as COD
                      await _clearCart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order Placed with Cash on Delivery")),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNav()));
                    },
                    child: const Text("Cash on Delivery"),
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
