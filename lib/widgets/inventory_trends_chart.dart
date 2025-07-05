import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryTrendsChart extends StatelessWidget {
  const InventoryTrendsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory_logs')
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("📉 No inventory trend data available."));
        }

        final docs = snapshot.data!.docs;
        final Map<String, Map<String, double>> trendMap = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;

          final timestamp = data['date'];
          final quantityRaw = data['quantity'];
          final itemName = data['item'] ?? 'Unknown';

          if (timestamp is Timestamp && quantityRaw is num) {
            final date = timestamp.toDate();
            final formattedDate = DateFormat('MMM d').format(date);

            trendMap[itemName] ??= {};
            trendMap[itemName]![formattedDate] =
                (trendMap[itemName]![formattedDate] ?? 0) + quantityRaw.toDouble();
          }
        }

        if (trendMap.isEmpty) {
          return const Center(child: Text("📉 Not enough inventory data."));
        }

        final allDates = <String>{};
        for (var itemTrends in trendMap.values) {
          allDates.addAll(itemTrends.keys);
        }
        final sortedDates = allDates.toList()..sort();

        final List<Color> colors = [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal
        ];

        int colorIndex = 0;
        final lines = trendMap.entries.map((entry) {
          final item = entry.key;
          final data = entry.value;
          final spots = List.generate(sortedDates.length, (i) {
            final value = data[sortedDates[i]] ?? 0.0;
            return FlSpot(i.toDouble(), value);
          });

          final color = colors[colorIndex++ % colors.length];

          return LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          );
        }).toList();

        return Column(
          children: [
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 5),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= sortedDates.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                sortedDates[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    lineBarsData: lines,
                    minY: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 12,
                children: trendMap.keys.map((item) {
                  final index = trendMap.keys.toList().indexOf(item);
                  final color = colors[index % colors.length];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: color),
                      const SizedBox(width: 4),
                      Text(item, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
