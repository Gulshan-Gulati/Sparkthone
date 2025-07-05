import 'package:flutter/material.dart';
import 'package:policeinventory/admins/addpolicestation.dart';
import 'package:policeinventory/admins/addproduct.dart';
import 'package:policeinventory/admins/bluetoothscreen.dart';
import 'package:policeinventory/admins/delteproduct.dart';
import 'package:policeinventory/admins/viewinventory.dart';
import 'package:policeinventory/admins/viewproduct.dart';
import 'package:policeinventory/admins/order_requests_page.dart';
import 'package:policeinventory/admins/analytics_dashboard.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
          children: [
            _buildDashboardCard(
              context,
              label: "Add Product",
              icon: Icons.add_circle_outline,
              color: Colors.deepPurple,
              destination: const AddProduct(),
            ),
            _buildDashboardCard(
              context,
              label: "Remove Product",
              icon: Icons.delete_outline,
              color: Colors.orangeAccent,
              destination: const DeleteProduct(),
            ),
            _buildDashboardCard(
              context,
              label: "View Product",
              icon: Icons.view_list,
              color: Colors.pink,
              destination: ViewProducts(),
            ),
            _buildDashboardCard(
              context,
              label: "Inventory Status",
              icon: Icons.inventory_2,
              color: Colors.green,
              destination: const ViewInventory(),
            ),
            _buildDashboardCard(
              context,
              label: "Bluetooth Tracking",
              icon: Icons.bluetooth_searching,
              color: Colors.teal,
              destination: BluetoothTrackingScreen(),
            ),
            _buildDashboardCard(
              context,
              label: "Manage Location",
              icon: Icons.local_police,
              color: Colors.amber,
              destination: const AddPoliceStationPage(),
            ),
            _buildDashboardCard(
              context,
              label: "Order Requests",
              icon: Icons.shopping_cart,
              color: Colors.indigo,
              destination: const OrderRequestsPage(),
            ),
            _buildDashboardCard(
              context,
              label: "Analytics Dashboard",
              icon: Icons.analytics,
              color: Colors.cyan,
              destination: const AnalyticsDashboard(), // ✅ Ensure this class exists
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
