import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:policeinventory/customer/view_inventory.dart';
import 'package:policeinventory/customer/product_location_page.dart';
import 'package:policeinventory/customer/make_request.dart';
import 'package:policeinventory/customer/weather_dashboard.dart';
import 'package:policeinventory/customer/maintenance_reminder_page.dart';
import 'package:policeinventory/customer/place_order_page.dart';
import 'package:policeinventory/customer/notice_page.dart';
import 'package:policeinventory/customer/my_orders_page.dart';
import 'package:policeinventory/chatbot/chatbot_page.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cardItems = [
      {
        "title": "View Inventory",
        "icon": Icons.inventory,
        "color": Colors.blue,
        "page": const ViewInventoryScreen()
      },
      {
        "title": "Make a Request",
        "icon": Icons.add_box,
        "color": Colors.orange,
        "page": const MakeRequestPage()
      },
      {
        "title": "Place Order",
        "icon": Icons.shopping_cart,
        "color": Colors.purple,
        "page": const PlaceOrderPage()
      },
      {
        "title": "My Orders",
        "icon": Icons.receipt_long,
        "color": Colors.cyan,
        "page": const MyOrdersPage()
      },
      {
        "title": "Product Location",
        "icon": Icons.location_searching,
        "color": Colors.green,
        "page": const ProductLocationPage()
      },
      {
        "title": "Weather",
        "icon": Icons.cloud_outlined,
        "color": Colors.lightBlue,
        "page": const WeatherDashboard()
      },
      {
        "title": "Notice",
        "icon": Icons.notifications,
        "color": Colors.red,
        "page": const MaintenanceReminderPage()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: const Color(0xFF0071CE), // Walmart Blue
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('order_notice')
                  .where('seen', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 28),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NoticePage()),
                        );

                        final batch = FirebaseFirestore.instance.batch();
                        for (var doc in snapshot.data!.docs) {
                          batch.update(doc.reference, {'seen': true});
                        }
                        await batch.commit();
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                              minWidth: 20, minHeight: 20),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Welcome 👋",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Explore and manage inventory, track orders, get weather updates, and more!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    itemCount: cardItems.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.05,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = cardItems[index];
                      return DashboardCard(
                        title: item["title"] as String,
                        icon: item["icon"] as IconData,
                        color: item["color"] as Color,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => item["page"] as Widget),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "Version 1.0.0 • Walmart Inventory",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),

      // ✅ Floating Chatbot Icon - Styled like Real
      floatingActionButton: Tooltip(
        message: "Chat with AI",
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotPage()),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12, right: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0071CE), // Walmart Blue
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
