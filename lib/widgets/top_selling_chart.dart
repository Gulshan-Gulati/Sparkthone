import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TopSellingChart extends StatelessWidget {
  const TopSellingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('product_stats').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        // Extract item -> count map
        final Map<String, int> itemCounts = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;

          final item = (data['item'] ?? 'Unknown') as String;
          final count = (data['totalOrdered'] ?? 0).toInt();

          if (item.isNotEmpty && count > 0) {
            itemCounts[item] = count;
          }
        }

        if (itemCounts.isEmpty) {
          return const Center(child: Text("No sales data available."));
        }

        // Sort and take top 5
        final topItems = itemCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final barGroups = <BarChartGroupData>[];

        for (int i = 0; i < topItems.length && i < 5; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: topItems[i].value.toDouble(),
                  color: const Color.fromARGB(255, 34, 122, 255),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
          );
        }

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: topItems.first.value.toDouble() + 2,
            barGroups: barGroups,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < topItems.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          topItems[index].key,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
          ),
        );
      },
    );
  }
}
