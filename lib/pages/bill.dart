import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hide_out_lounge/components/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Red theme colors
const Color primaryRed = Color(0xFFC02828);
const Color darkRed = Color(0xFF9A1A1A);
const Color backgroundWhite = Color(0xFFFFFFFF);

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
  State<BillPage> createState() => _BillPageState();
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

  Future<String> _placeOrder({String paymentMethod = 'COD', String paymentStatus = 'pending'}) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set({
      'userId': widget.userId,
      'cartItems': widget.cartItems.map((item) => item.data()).toList(),
      'address': widget.address,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': 'Pending',
      'orderDate': Timestamp.now(),
      'receiptUrl': '',
    });
    return orderRef.id;
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

  void _showUPIPaymentDialog() {
    final parentContext = context;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UPI Payment', style: TextStyle(color: primaryRed)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Scan the QR code below to make payment:'),
              const SizedBox(height: 20),
              Image.asset('assets/upi_qr.png', height: 200),
              const SizedBox(height: 20),
              const Text('OR', style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed)),
              const SizedBox(height: 10),
              SelectableText(
                'UPI ID: your.upi@id',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryRed),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: primaryRed),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                if (!parentContext.mounted) return;
                
                final orderId = await _placeOrder(
                  paymentMethod: 'UPI', 
                  paymentStatus: 'pending_verification'
                );
                
                await _clearCart();

                if (!parentContext.mounted) return;
                
                Navigator.of(parentContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ReceiptUploadScreen(orderId: orderId),
                  ),
                );
              } catch (e) {
                if (!parentContext.mounted) return;
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text('Error processing order: $e')),
                );
              }
            },
            child: const Text('Proceed to Upload Receipt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        backgroundColor: primaryRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Address:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryRed),
            ),
            const SizedBox(height: 10),
            Text(widget.address, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 20),
            const Text(
              "Order Items:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryRed),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    leading: Image.network(
                      item['Image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['Name'], style: const TextStyle(color: Colors.black87)),
                    subtitle: Text("Qty: ${item['Quantity']}", style: const TextStyle(color: Colors.black54)),
                    trailing: Text("₹${item['Total']}", style: const TextStyle(color: primaryRed)),
                  );
                },
              ),
            ),
            const Divider(color: primaryRed),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryRed),
                  ),
                  Text(
                    "₹${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _showUPIPaymentDialog,
                    child: const Text(
                      "Pay via UPI",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      final orderId = await _placeOrder();
                      await _clearCart();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderConfirmationScreen(orderId: orderId),
                        ),
                      );
                    },
                    child: const Text(
                      "Cash on Delivery",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

class ReceiptUploadScreen extends StatefulWidget {
  final String orderId;

  const ReceiptUploadScreen({required this.orderId, super.key});

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  File? _receiptImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _receiptImage = File(pickedFile.path));
    }
  }

  Future<void> _uploadReceipt() async {
    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a receipt first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('receipts/${widget.orderId}/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_receiptImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'receiptUrl': downloadUrl,
            'paymentStatus': 'pending_verification',
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(orderId: widget.orderId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Payment Receipt', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Upload Payment Receipt',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryRed),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryRed),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _receiptImage != null
                    ? Image.file(_receiptImage!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.receipt, size: 50, color: primaryRed),
                          SizedBox(height: 10),
                          Text('Tap to select payment receipt', style: TextStyle(color: primaryRed)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 30),
            _isUploading
                ? const CircularProgressIndicator(color: primaryRed)
                : ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
                    label: const Text('Upload Receipt', style: TextStyle(color: Colors.white)),
                    onPressed: _uploadReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;

  const OrderConfirmationScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: primaryRed),
              const SizedBox(height: 20),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryRed),
              ),
              const SizedBox(height: 20),
              Text(
                'Order ID: $orderId',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNav()),
                  (route) => false,
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}