import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateOrderStatusPage extends StatefulWidget {
  const UpdateOrderStatusPage({super.key});

  @override
  State<UpdateOrderStatusPage> createState() => _UpdateOrderStatusPageState();
}

class _UpdateOrderStatusPageState extends State<UpdateOrderStatusPage> {
  String? selectedOrderId;
  String? selectedStatus;

  final List<String> statusOptions = [
    "Ordered",
    "Packed",
    "Shipped",
    "Out for Delivery",
    "Delivered"
  ];

  Future<List<String>> fetchOrderIds() async {
    final snapshot = await FirebaseFirestore.instance.collection('orders').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> updateOrderStatus() async {
    if (selectedOrderId == null || selectedStatus == null) return;

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(selectedOrderId)
        .update({'status': selectedStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order $selectedOrderId updated to '$selectedStatus'")),
    );
    setState(() {
      selectedOrderId = null;
      selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Order Status"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<String>>(
          future: fetchOrderIds(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final orderIds = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Order ID:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedOrderId,
                  hint: const Text("Choose Order"),
                  items: orderIds.map((id) {
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(id),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedOrderId = value;
                  }),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Select Status:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedStatus,
                  hint: const Text("Choose Status"),
                  items: statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedStatus = value;
                  }),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: updateOrderStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                  ),
                  child: const Text("Update Status"),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
