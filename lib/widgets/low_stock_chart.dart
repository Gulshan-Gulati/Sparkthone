import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LowStockChart extends StatelessWidget {
  const LowStockChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory_logs') // ✅ Make sure data is logged here
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("⚠️ No low-stock data available."));
        }

        final docs = snapshot.data!.docs;
        final Map<String, int> lowStockCount = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final item = data['item'] ?? 'Unknown';
          final quantity = data['quantity'] ?? 0;

          // ✅ Updated threshold to <= 10
          if (quantity is num && quantity <= 10) {
            lowStockCount[item] = (lowStockCount[item] ?? 0) + 1;
          }
        }

        final entries = lowStockCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (entries.isEmpty) {
          return const Center(child: Text("✅ No items with low stock (≤ 10)."));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: BarChart(
            BarChartData(
              barGroups: List.generate(entries.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entries[i].value.toDouble(),
                      color: Colors.redAccent,
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= entries.length) return const SizedBox();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          entries[index].key,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        );
      },
    );
  }
}
