import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRequestsPage extends StatelessWidget {
  const OrderRequestsPage({super.key});

  Future<void> _updateOrderStatus(
    BuildContext context,
    String docId,
    String newStatus,
    Map<String, dynamic> orderData,
  ) async {
    try {
      // Update order status in 'orders' collection
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'status': newStatus,
      });

      // ✅ Log to 'product_stats' if order is approved
      if (newStatus == 'Approved') {
        final itemName = orderData['item'] ?? 'Unknown item';
        final quantity = orderData['quantity'] ?? 1;

        await FirebaseFirestore.instance.collection('product_stats').add({
          'item': itemName,
          'quantity': quantity,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Prepare order notice
      final itemName = orderData['item'] ?? 'Unknown item';
      final noticeMessage = newStatus == 'Approved'
          ? "✅ Your order for $itemName has been approved."
          : "❌ Your order for $itemName was rejected.";

      // Add notice to 'order_notice' collection
      await FirebaseFirestore.instance.collection('order_notice').add({
        'title': '📦 Order $newStatus',
        'message': noticeMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });

      // Show confirmation if context is still valid
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order marked as $newStatus")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const statusOptions = ['Pending', 'Approved', 'Rejected'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Requests"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No order requests yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    "${data['item'] ?? 'Unnamed Item'} (x${data['quantity'] ?? '-'})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Requested by: ${data['name'] ?? 'Unknown'}"),
                      Text("Department: ${data['department'] ?? 'N/A'}"),
                      Text("Status: $status"),
                      if (data['preferredDate'] != null &&
                          data['preferredDate'].toString().isNotEmpty)
                        Text("Preferred Date: ${data['preferredDate'].toString().split('T').first}"),
                    ],
                  ),
                  trailing: DropdownButton<String>(
                    value: statusOptions.contains(status) ? status : null,
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                    items: statusOptions.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: value == 'Approved'
                                ? Colors.green
                                : value == 'Rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null && newValue != status) {
                        _updateOrderStatus(context, doc.id, newValue, data);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
