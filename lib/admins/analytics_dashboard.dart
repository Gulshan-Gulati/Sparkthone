import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/top_selling_chart.dart';
import '../widgets/inventory_trends_chart.dart';
import '../widgets/low_stock_chart.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📈 Analytics Dashboard"),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("📊 Inventory Trends"),
            const SizedBox(
              height: 200,
              child: InventoryTrendsChart(),
            ),

            _buildSectionHeader("🔥 Top-Selling Items"),
            const SizedBox(
              height: 200,
              child: TopSellingChart(),
            ),

            _buildSectionHeader("⚠️ Low-Stock Frequency"),
            const SizedBox(
              height: 200,
              child: LowStockChart(),
            ),

            _buildSectionHeader("📦 Pending Orders"),
            const SizedBox(height: 16),
            _buildOrderAnalyticsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOrderAnalyticsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final approved = docs.where((d) => d['status'] == 'Approved').length;
        final pending = docs.where((d) => d['status'] == 'Pending').length;
        final rejected = docs.where((d) => d['status'] == 'Rejected').length;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.indigo.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusBox("✅ Approved", approved, Colors.green),
                _buildStatusBox("🕒 Pending", pending, Colors.orange),
                _buildStatusBox("❌ Rejected", rejected, Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBox(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
