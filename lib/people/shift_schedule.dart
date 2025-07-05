import 'dart:math';
import 'package:flutter/material.dart';

class ShiftSchedule {
  final String name;
  final String date;
  final String time;
  final String location;

  ShiftSchedule({
    required this.name,
    required this.date,
    required this.time,
    required this.location,
  });
}

class ShiftSchedulePage extends StatelessWidget {
  ShiftSchedulePage({super.key});

  final List<String> names = [
    "Rohan Sharma",
    "Neha Singh",
    "Amit Verma",
    "Priya Patel",
    "Karan Mehta",
    "Sneha Roy",
    "Rahul Das",
    "Anjali Kumari",
    "Deepak Sinha",
    "Meena Joshi"
  ];

  final List<String> times = [
    "08:00 AM - 04:00 PM",
    "09:00 AM - 05:00 PM",
    "10:00 AM - 06:00 PM",
    "11:00 AM - 07:00 PM",
    "02:00 PM - 10:00 PM"
  ];

  final List<String> locations = [
    "Central Station",
    "West Side Station",
    "East Side Station",
    "North Station",
    "South Station"
  ];

  final Random _random = Random();

  List<ShiftSchedule> generateSchedules() {
    List<ShiftSchedule> schedules = [];
    DateTime today = DateTime.now();

    for (int i = 0; i < 10; i++) {
      String name = names[i];
      String date = "${today.add(Duration(days: i)).toLocal()}".split(' ')[0];
      String time = times[_random.nextInt(times.length)];
      String location = locations[_random.nextInt(locations.length)];

      schedules.add(ShiftSchedule(
        name: name,
        date: date,
        time: time,
        location: location,
      ));
    }

    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    final schedules = generateSchedules();

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Shift Schedule"),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upcoming Staff Shifts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final shift = schedules[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.red[50],
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.red),
                      title: Text(
                        shift.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${shift.date}"),
                          Text("Time: ${shift.time}"),
                          Text("Location: ${shift.location}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
