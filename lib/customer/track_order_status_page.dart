import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackOrderStatusPage extends StatefulWidget {
  final String orderId;

  const TrackOrderStatusPage({super.key, required this.orderId});

  @override
  State<TrackOrderStatusPage> createState() => _TrackOrderStatusPageState();
}

class _TrackOrderStatusPageState extends State<TrackOrderStatusPage> {
  final List<String> statusSteps = [
    "Ordered",
    "Packed",
    "Shipped",
    "Out for Delivery",
    "Delivered",
  ];

  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': 'Cancelled'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order has been cancelled.")),
      );

      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Order #${widget.orderId}"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final currentStatus = orderData['status'] ?? 'Ordered';
          final currentIndex = statusSteps.indexOf(currentStatus);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Progress",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: statusSteps.length,
                    itemBuilder: (context, index) {
                      final isDone = index <= currentIndex;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    isDone ? Colors.teal : Colors.grey[300],
                                child: Icon(
                                  isDone
                                      ? Icons.check
                                      : Icons.radio_button_unchecked,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              if (index < statusSteps.length - 1)
                                Container(
                                  height: 40,
                                  width: 2,
                                  color: isDone ? Colors.teal : Colors.grey[300],
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              statusSteps[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDone
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (currentStatus != 'Delivered' &&
                      currentStatus != 'Cancelled')
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _cancelOrder,
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancel Order"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  if (currentStatus == 'Cancelled')
                    Center(
                      child: Text(
                        "This order has been cancelled.",
                        style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const Text(
                    "Feedback",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your experience...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Rate your experience:"),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('feedback')
                          .add({
                        'orderId': widget.orderId,
                        'rating': _rating,
                        'comment': _feedbackController.text.trim(),
                        'timestamp': Timestamp.now(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Feedback submitted")),
                      );

                      _feedbackController.clear();
                      setState(() {
                        _rating = 0;
                      });
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Submit Feedback"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
