import 'package:flutter/material.dart';
import 'package:policeinventory/people/shift_schedule.dart';
import 'package:policeinventory/people/inventory_page.dart';
import 'package:policeinventory/people/assigned_tasks_page.dart';
import 'package:policeinventory/people/clock_in_clock_out.dart';
import 'package:policeinventory/people/leave_application_form.dart';
import 'package:policeinventory/people/notices_page.dart';
import 'package:policeinventory/people/update_order_status_page.dart';

class PeopleDashboard extends StatelessWidget {
  const PeopleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Staff Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Staff 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Select an option below to get started.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _dashboardTile(
                    context,
                    icon: Icons.schedule,
                    label: "Shift Schedule",
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ShiftSchedulePage()),
                    ),
                  ),
                  _dashboardTile(
                    context,
                    icon: Icons.inventory_2,
                    label: "Inventory",
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InventoryPage()),
                    ),
                  ),
                  _dashboardTile(
                    context,
                    icon: Icons.assignment,
                    label: "My Tasks",
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AssignedTasksPage()),
                    ),
                  ),
                  _dashboardTile(
                    context,
                    icon: Icons.access_time,
                    label: "Clock In/Out",
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClockInOutPage()),
                    ),
                  ),
                  _dashboardTile(
                    context,
                    icon: Icons.request_page,
                    label: "Leave Request",
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LeaveApplicationForm()),
                    ),
                  ),
                  _dashboardTile(
                    context,
                    icon: Icons.notifications,
                    label: "View Notices",
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoticesPage()),
                    ),
                  ),
                  _dashboardTile(
                    context,
                    icon: Icons.update,
                    label: "Update Order Status", // ✅ NEW TILE
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UpdateOrderStatusPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                label,
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
