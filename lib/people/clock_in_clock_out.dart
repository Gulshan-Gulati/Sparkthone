import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  DateTime? clockInTime;
  DateTime? clockOutTime;
  bool isClockedIn = false;
  Duration liveDuration = Duration.zero;
  Timer? timer;

  final List<Map<String, String>> clockHistory = [];

  void _clockIn() {
    if (isClockedIn) return;
    setState(() {
      clockInTime = DateTime.now();
      clockOutTime = null;
      isClockedIn = true;
      liveDuration = Duration.zero;

      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          liveDuration = DateTime.now().difference(clockInTime!);
        });
      });
    });
  }

  void _clockOut() {
    if (!isClockedIn) return;
    setState(() {
      clockOutTime = DateTime.now();
      isClockedIn = false;
      timer?.cancel();
      timer = null;

      if (clockInTime != null) {
        final duration = clockOutTime!.difference(clockInTime!);
        clockHistory.insert(0, {
          'date': DateFormat('yyyy-MM-dd').format(clockInTime!),
          'in': DateFormat('hh:mm a').format(clockInTime!),
          'out': DateFormat('hh:mm a').format(clockOutTime!),
          'duration': '${duration.inHours}h ${duration.inMinutes.remainder(60)}m'
        });
        if (clockHistory.length > 5) {
          clockHistory.removeLast();
        }
      }
    });
  }

  String _formatTime(DateTime? time) {
    return time != null ? DateFormat('hh:mm a').format(time) : "--:--";
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workedDuration = (clockInTime != null && clockOutTime != null)
        ? clockOutTime!.difference(clockInTime!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In / Clock Out'),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isClockedIn ? 'Status: Clocked In ✅' : 'Status: Not Clocked In ❌',
              style: TextStyle(
                fontSize: 18,
                color: isClockedIn ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text("Today's Shift Summary", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Clock In: ${_formatTime(clockInTime)}"),
                Text("Clock Out: ${_formatTime(clockOutTime)}"),
              ],
            ),
            const SizedBox(height: 10),
            if (isClockedIn)
              Text(
                "Elapsed Time: ${_formatDuration(liveDuration)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
              )
            else if (workedDuration != null)
              Text(
                "Total Worked: ${workedDuration.inHours}h ${workedDuration.inMinutes.remainder(60)}m",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(isClockedIn ? Icons.logout : Icons.login),
                label: Text(isClockedIn ? "Clock Out" : "Clock In"),
                onPressed: isClockedIn ? _clockOut : _clockIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClockedIn ? Colors.red : Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text("Recent Clock History", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: clockHistory.isEmpty
                  ? const Center(child: Text("No history available."))
                  : ListView.builder(
                      itemCount: clockHistory.length,
                      itemBuilder: (context, index) {
                        final entry = clockHistory[index];
                        return ListTile(
                          title: Text("${entry['date']}"),
                          subtitle: Text(
                              "In: ${entry['in']}  |  Out: ${entry['out']}  |  Duration: ${entry['duration']}"),
                          leading: const Icon(Icons.history),
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
