import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ NEW

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({super.key});

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentDetailController = TextEditingController();

  DateTime? _preferredDate;
  String _priority = 'Normal';
  String _selectedPaymentMethod = 'Cash on Delivery';
  bool isSubmitting = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;

    final orderData = {
      'customerId': user?.uid, // ✅ Track user who placed order
      'name': _nameController.text.trim(),
      'department': _departmentController.text.trim(),
      'item': _itemController.text.trim(),
      'quantity': _quantityController.text.trim(),
      'address': _addressController.text.trim(),
      'zipCode': _zipCodeController.text.trim(),
      'contact': _contactController.text.trim(),
      'notes': _notesController.text.trim(),
      'preferredDate': _preferredDate?.toIso8601String() ?? '',
      'priority': _priority,
      'paymentMethod': _selectedPaymentMethod,
      'paymentDetails': _paymentDetailController.text.trim(),
      'status': 'Ordered', // ✅ Starting status
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // 🔔 Send order notice
      await FirebaseFirestore.instance.collection('order_notice').add({
        'title': '🛒 Order Placed',
        'message':
            'Order placed for ${_itemController.text.trim()} x${_quantityController.text.trim()} by ${_nameController.text.trim()}.',
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully.")),
      );

      _formKey.currentState!.reset();
      setState(() {
        _priority = 'Normal';
        _preferredDate = null;
        _selectedPaymentMethod = 'Cash on Delivery';
        _paymentDetailController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to place order: $e")),
      );
    }

    setState(() => isSubmitting = false);
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.deepPurple.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) {
                  setState(() => _preferredDate = picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _preferredDate == null
                      ? "Preferred Delivery Date"
                      : "Preferred: ${_preferredDate!.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(
                    color: _preferredDate == null
                        ? Colors.grey.shade600
                        : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _priority,
        items: ['Low', 'Normal', 'High'].map((priority) {
          return DropdownMenuItem(value: priority, child: Text(priority));
        }).toList(),
        decoration: InputDecoration(
          labelText: "Order Priority",
          filled: true,
          fillColor: Colors.deepPurple.shade50,
          prefixIcon: const Icon(Icons.priority_high, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (val) {
          setState(() => _priority = val ?? 'Normal');
        },
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "💳 Payment Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          items: [
            'Cash on Delivery',
            'UPI',
            'Credit/Debit Card',
            'Net Banking'
          ].map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          decoration: InputDecoration(
            labelText: "Payment Method",
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            prefixIcon: const Icon(Icons.payment, color: Colors.deepPurple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (val) {
            setState(() => _selectedPaymentMethod = val ?? 'Cash on Delivery');
          },
        ),
        if (_selectedPaymentMethod != 'Cash on Delivery') ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: _paymentDetailController,
            decoration: InputDecoration(
              labelText: _selectedPaymentMethod == 'UPI'
                  ? "Enter UPI ID"
                  : _selectedPaymentMethod == 'Credit/Debit Card'
                      ? "Card Number (**** **** **** 1234)"
                      : "Enter Payment Reference",
              prefixIcon:
                  const Icon(Icons.credit_card, color: Colors.deepPurple),
              filled: true,
              fillColor: Colors.deepPurple.shade50,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (_selectedPaymentMethod != 'Cash on Delivery' &&
                  (value == null || value.isEmpty)) {
                return 'Please enter payment details';
              }
              return null;
            },
          ),
        ]
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    _paymentDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Product Order"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📝 Order Form",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                      label: "Name", icon: Icons.person, controller: _nameController),
                  _buildTextField(
                      label: "Department",
                      icon: Icons.apartment,
                      controller: _departmentController),
                  _buildTextField(
                      label: "Item Name",
                      icon: Icons.shopping_bag,
                      controller: _itemController),
                  _buildTextField(
                      label: "Quantity",
                      icon: Icons.format_list_numbered,
                      controller: _quantityController,
                      inputType: TextInputType.number),
                  _buildTextField(
                      label: "Delivery Address",
                      icon: Icons.location_on,
                      controller: _addressController),
                  _buildTextField(
                      label: "Zip Code",
                      icon: Icons.markunread_mailbox,
                      controller: _zipCodeController,
                      inputType: TextInputType.number),
                  _buildTextField(
                      label: "Contact Number",
                      icon: Icons.phone,
                      controller: _contactController,
                      inputType: TextInputType.phone),
                  _buildDatePicker(),
                  _buildPriorityDropdown(),
                  _buildTextField(
                      label: "Additional Notes",
                      icon: Icons.note,
                      controller: _notesController,
                      maxLines: 3),
                  _buildPaymentSection(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submitOrder,
                      icon: const Icon(Icons.send),
                      label: Text(
                          isSubmitting ? "Submitting..." : "Submit Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
