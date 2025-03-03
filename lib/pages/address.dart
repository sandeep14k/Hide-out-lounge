import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressSelectionPage extends StatefulWidget {
  final String userId;
  final List<DocumentSnapshot> cartItems;
  static const LatLng storeLocation = LatLng(25.7587155979808, 86.03146357566138);

  const AddressSelectionPage({
    required this.userId,
    required this.cartItems,
    super.key,
  });

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  LatLng? selectedLocation;
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const LatLng storeLocation = LatLng(25.7587155979808, 86.03146357566138);
  static const double maxDeliveryRadius = 20000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 187, 36, 36),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').doc(widget.userId).collection('addresses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildAddNewAddressSection();
                }

                return ListView(
                  children: [
                    _buildSectionHeader('Saved Addresses'),
                    ...snapshot.data!.docs.map((doc) => _buildAddressCard(doc)),
                    _buildSectionHeader('Add New Address'),
                    _buildAddNewAddressButton(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

Widget _buildAddressCard(DocumentSnapshot doc) {
  final address = doc['formattedAddress'];
  final location = LatLng(doc['latitude'], doc['longitude']);
  
  return Card(
    margin: const EdgeInsets.all(8),
    child: ListTile(
      title: Text(address),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => _validateAndProceed(location, address),
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAddNewAddressSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No saved addresses found. Please add a new address.',
            textAlign: TextAlign.center,
          ),
        ),
        _buildAddNewAddressButton(),
      ],
    );
  }

  Widget _buildAddNewAddressButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('ADD NEW ADDRESS', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 187, 36, 36),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewAddressPage(
              userId: widget.userId,
              onAddressAdded: (latLng) => _validateAndProceed(latLng, 'New Address'),
            ),
          ),
        ),
      ),
    );
  }
Future<void> _validateAndProceed(LatLng location, String formattedAddress) async {
  setState(() => isLoading = true);

  try {
    // Calculate distance between store and selected location
    final distance = await Geolocator.distanceBetween(
      storeLocation.latitude,
      storeLocation.longitude,
      location.latitude,
      location.longitude,
    );

    // Calculate total order amount
    final totalAmount = _calculateTotalAmount();
    String errorMessage = '';

    // Validate distance and order amount
    if (distance > maxDeliveryRadius) {
      errorMessage = 'Delivery unavailable beyond 20km';
    } else if (distance > 12000) {
      if (totalAmount < 1500) errorMessage = 'Minimum order for 12-20km: ₹1500';
    } else if (totalAmount < 300) {
      errorMessage = 'Minimum order within 12km: ₹300';
    }

    // Show error dialog if validation fails
    if (errorMessage.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Requirement'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Return formatted address if validation passes
    if (mounted) {
      Navigator.pop(context, formattedAddress);
    }
  } catch (e) {
    // Handle errors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    // Reset loading state
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

 double _calculateTotalAmount() {
  return widget.cartItems.fold(0.0, (sum, item) {
    final total = item['Total'];
    if (total is String) return sum + double.parse(total);
    if (total is num) return sum + total.toDouble();
    return sum;
  });
}
}

class NewAddressPage extends StatefulWidget {
  final String userId;
  final Function(LatLng) onAddressAdded;

  const NewAddressPage({
    required this.userId,
    required this.onAddressAdded,
    super.key,
  });

  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  LatLng? selectedLocation;
  bool isLoading = false;

Future<void> _saveAddress() async {
  // Validate selected location
  if (selectedLocation == null) {
    _showError('Please select a location');
    return;
  }

  // Validate required fields
  if (nameController.text.isEmpty ||
      mobileController.text.isEmpty ||
      cityController.text.isEmpty ||
      districtController.text.isEmpty ||
      villageController.text.isEmpty ||
      streetController.text.isEmpty ||
      houseController.text.isEmpty) {
    _showError('Please fill all required fields');
    return;
  }

  setState(() => isLoading = true);

  try {
    // Prepare address data for Firestore
    final addressData = {
      'name': nameController.text,
      'mobile': mobileController.text,
      'city': cityController.text,
      'district': districtController.text,
      'village': villageController.text,
      'street': streetController.text,
      'house': houseController.text,
      'landmark': landmarkController.text,
      'latitude': selectedLocation!.latitude,
      'longitude': selectedLocation!.longitude,
      'formattedAddress': _formatAddress(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Save address to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('addresses')
        .add(addressData);

    // Return formatted address to previous screen
    if (mounted) {
      Navigator.pop(context, _formatAddress());
    }
  } catch (e) {
    // Handle errors
    if (mounted) {
      _showError('Error saving address: $e');
    }
  } finally {
    // Reset loading state
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

 String _formatAddress() {
  return '''
${houseController.text}, ${streetController.text}
${villageController.text}, ${cityController.text}
${districtController.text}
Landmark: ${landmarkController.text}
''';
}

  Future<void> _handleLocationSelection() async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Current Location'),
              onTap: () async {
                final position = await _getCurrentLocation();
                Navigator.pop(context, position);
              },
            ),
           ListTile(
  leading: const Icon(Icons.map),
  title: const Text('Choose from Map'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MapSelectionScreen(
        initialPosition: AddressSelectionPage.storeLocation,
      ),
    ),
  ).then((value) => Navigator.pop(context, value)),
),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => selectedLocation = result);
    }
  }

  Future<LatLng> _getCurrentLocation() async {
    if (!await _checkLocationPermission()) throw Exception('Location permission denied');
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return true;
  }

  void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
        backgroundColor: const Color.fromARGB(255, 187, 36, 36),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLocationSelector(),
            const SizedBox(height: 20),
            _buildAddressForm(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (selectedLocation != null)
              Text(
                'Selected Location: ${selectedLocation!.latitude.toStringAsFixed(4)}, '
                '${selectedLocation!.longitude.toStringAsFixed(4)}',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleLocationSelection,
              child: const Text('Choose Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        _buildTextField(nameController, 'Full Name *', Icons.person),
        _buildTextField(mobileController, 'Mobile Number *', Icons.phone, keyboardType: TextInputType.phone),
        _buildTextField(cityController, 'City *', Icons.location_city),
        _buildTextField(districtController, 'District *', Icons.map),
        _buildTextField(villageController, 'Village/Town *', Icons.home_work),
        _buildTextField(streetController, 'Street *', Icons.streetview),
        _buildTextField(houseController, 'House No/Flat No *', Icons.home),
        _buildTextField(landmarkController, 'Landmark', Icons.flag),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            hintText: label.contains('*') ? null : 'Optional',
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 187, 36, 36),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isLoading ? null : _saveAddress,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('SAVE ADDRESS', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// Keep the existing MapSelectionScreen implementation
class MapSelectionScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapSelectionScreen({
    required this.initialPosition,
    Key? key,
  }) : super(key: key);

  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Location'),
        backgroundColor: const Color.fromARGB(255, 187, 36, 36),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 14,
        ),
        onMapCreated: (controller) => _mapController = controller,
        onTap: (LatLng position) => setState(() => _selectedLocation = position),
        markers: _selectedLocation != null
            ? {Marker(markerId: const MarkerId('selected'), position: _selectedLocation!)}
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 187, 36, 36),
        onPressed: () {
          if (_selectedLocation != null) Navigator.pop(context, _selectedLocation!);
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}