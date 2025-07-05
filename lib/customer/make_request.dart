import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MakeRequestPage extends StatefulWidget {
  const MakeRequestPage({super.key});

  @override
  State<MakeRequestPage> createState() => _MakeRequestPageState();
}

class _MakeRequestPageState extends State<MakeRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  bool isSubmitting = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final name = _nameController.text.trim();
    final department = _departmentController.text.trim();
    final item = _itemNameController.text.trim();
    final quantity = _quantityController.text.trim();
    final reason = _reasonController.text.trim();

    try {
      // 1️⃣ Add the request
      await FirebaseFirestore.instance.collection('requests').add({
        'name': name,
        'department': department,
        'item': item,
        'quantity': quantity,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2️⃣ Add a standard notice
      await FirebaseFirestore.instance.collection('notices').add({
        'title': "Request Submitted by $name",
        'description':
            "$department requested $quantity x $item.\nReason: $reason",
        'date': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Weather-based delay check
      await _checkWeatherAndAddNotice(department, item);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request & Notice submitted!")),
      );

      // Clear form
      _nameController.clear();
      _departmentController.clear();
      _itemNameController.clear();
      _quantityController.clear();
      _reasonController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSubmitting = false);
  }

  Future<void> _checkWeatherAndAddNotice(String department, String item) async {
    final String apiKey = '7ba884ae93ed66021bdb1272ab6dfcd6';
    const String city = 'Patna';
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List forecasts = data['list'];

        for (var forecast in forecasts.take(5)) {
          final condition =
              forecast['weather'][0]['main'].toString().toLowerCase();
          if (condition.contains('rain') ||
              condition.contains('storm') ||
              condition.contains('thunder')) {
            await FirebaseFirestore.instance.collection('notices').add({
              'title': "Weather Alert: Delay Possible",
              'description':
                  "Due to upcoming bad weather in $city, the request for $item by $department may be delayed.",
              'date': FieldValue.serverTimestamp(),
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Weather check failed: $e");
    }
  }

  Widget buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Please enter $hint" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make a Request"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Request Form",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                buildInputField(
                    icon: Icons.person,
                    hint: "Your Name",
                    controller: _nameController),
                buildInputField(
                    icon: Icons.apartment,
                    hint: "Department",
                    controller: _departmentController),
                buildInputField(
                    icon: Icons.inventory_2,
                    hint: "Item Name",
                    controller: _itemNameController),
                buildInputField(
                    icon: Icons.onetwothree,
                    hint: "Quantity",
                    controller: _quantityController),
                buildInputField(
                    icon: Icons.edit_note,
                    hint: "Reason",
                    controller: _reasonController,
                    maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _submitRequest,
                    icon: const Icon(Icons.send),
                    label: Text(
                      isSubmitting ? "Submitting..." : "Submit Request",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
