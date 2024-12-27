import 'package:flutter/material.dart';
import 'package:hide_out_lounge/service/shared_prefrence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddressSelectionPage extends StatefulWidget {
 final String userId;
final List<DocumentSnapshot> cartItems;

const AddressSelectionPage({
  required this.userId,
  required this.cartItems,
  super.key,
});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  List<String> addresses = [];

  @override
  void initState() {
    super.initState();
    loadSavedAddresses();
  }

  Future<void> loadSavedAddresses() async {
    final savedAddresses = await SharedPreferenceHelper.getSavedAddresses();
    setState(() {
      addresses = savedAddresses ?? [];
    });
  }

  Future<void> saveNewAddress(Map<String, String> addressDetails) async {
    String address = """
    Name: ${addressDetails['name']}
    Mobile: ${addressDetails['mobile']}
    City: ${addressDetails['city']}
    District: ${addressDetails['district']}
    Village: ${addressDetails['village']}
    Street: ${addressDetails['street']}
    House No: ${addressDetails['house']}
    Landmark: ${addressDetails['landmark']}
    """;

    await SharedPreferenceHelper.saveAddress(address);
    loadSavedAddresses();
  }

  void proceedToCheckout(String selectedAddress) {
    Navigator.pop(context, selectedAddress);
  }

  void showAddNewAddressDialog() {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final cityController = TextEditingController();
    final districtController = TextEditingController();
    final villageController = TextEditingController();
    final streetController = TextEditingController();
    final houseController = TextEditingController();
    final landmarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: districtController,
                  decoration: const InputDecoration(
                    labelText: "District",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: villageController,
                  decoration: const InputDecoration(
                    labelText: "Village",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: "Street",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: houseController,
                  decoration: const InputDecoration(
                    labelText: "House Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: landmarkController,
                  decoration: const InputDecoration(
                    labelText: "Nearby Landmark",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, String> addressDetails = {
                  'name': nameController.text,
                  'mobile': mobileController.text,
                  'city': cityController.text,
                  'district': districtController.text,
                  'village': villageController.text,
                  'street': streetController.text,
                  'house': houseController.text,
                  'landmark': landmarkController.text,
                };
                saveNewAddress(addressDetails);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Save Address"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address",style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: addresses.isEmpty
                ? const Center(
                    child: Text(
                      "No saved addresses found.",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(addresses[index]),
                        leading: const Icon(Icons.location_on),
                        trailing: ElevatedButton(
                          onPressed: () => proceedToCheckout(addresses[index]),
                          child: const Text("Select"),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: showAddNewAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add New Address"),
            ),
          ),
        ],
      ),
    );
  }
}