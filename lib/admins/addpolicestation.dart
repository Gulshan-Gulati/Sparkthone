import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:policeinventory/auth/auth_service.dart'; // Custom AuthService

// Add Police Station Page
class AddPoliceStationPage extends StatefulWidget {
  const AddPoliceStationPage({super.key});

  @override
  _AddPoliceStationPageState createState() => _AddPoliceStationPageState();
}

class _AddPoliceStationPageState extends State<AddPoliceStationPage> {
  final AuthService _auth = AuthService(); // Instance of AuthService
  final TextEditingController _assignedManagerController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _assignedManagerController.dispose();
    _emailController.dispose();
    _productIdController.dispose();
    _stationNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Generate a random station ID
  void _generateproductId() {
    final generatedId = 'ST-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _productIdController.text = generatedId;
    });
  }

  // Submit station details and create Firebase user
  Future<void> _submitDetails() async {
    final assignedManager = _assignedManagerController.text;
    final email = _emailController.text;
    final productId = _productIdController.text;
    final stationName = _stationNameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate inputs
    if (assignedManager.isNotEmpty &&
        email.isNotEmpty &&
        productId.isNotEmpty &&
        stationName.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password != confirmPassword) {
        _showSnackBar('Passwords do not match!');
        return;
      }

      // Attempt to create user with Firebase Auth
      try {
        final user = await _auth.createUserWithEmailAndPassword(
            email, password, context);
        if (user != null) {
          // If user creation is successful, store police station info in Firestore
          await FirebaseFirestore.instance.collection('policestations').add({
            'assignedManager': assignedManager,
            'email': email,
            'productId': productId,
            'stationInventory': [],
            'stationName': stationName,
            // Password is not stored here for security reasons
          });

          _showSnackBar('Police station details submitted successfully!');
          _clearFields();
        }
      } catch (e) {
        _showSnackBar('Failed to submit details. Please try again.');
      }
    } else {
      _showSnackBar('Please fill in all fields!');
    }
  }

  // Clear all input fields
  void _clearFields() {
    _assignedManagerController.clear();
    _emailController.clear();
    _productIdController.clear();
    _stationNameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  // Show a SnackBar for user feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Walmart Store'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _assignedManagerController,
              decoration: const InputDecoration(
                labelText: 'Assigned Manager',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _productIdController,
              decoration: InputDecoration(
                labelText: 'Walmart Store ID (Auto-generated)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.autorenew),
                  onPressed: _generateproductId,
                ),
              ),
              readOnly: true, // Make it read-only since it's auto-generated
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stationNameController,
              decoration: const InputDecoration(
                labelText: 'Walmart Place Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitDetails,
              child: const Text('Submit Details'),
            ),
          ],
        ),
      ),
    );
  }
}
