import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final String apiKey = '7ba884ae93ed66021bdb1272ab6dfcd6';
  final TextEditingController cityController = TextEditingController();

  List<dynamic> forecastData = [];
  bool isLoading = false;
  bool isError = false;
  bool hasSearched = false;

  Future<void> fetchForecast(String city) async {
    if (city.isEmpty) return;

    setState(() {
      isLoading = true;
      isError = false;
      hasSearched = true;
      forecastData = [];
    });

    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final filtered = (data['list'] as List).where((item) {
          final dtTxt = item['dt_txt'];
          return dtTxt is String && dtTxt.contains("12:00:00");
        }).toList();

        setState(() {
          forecastData = filtered;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load forecast');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print("Error fetching forecast: $e");
    }
  }

  String getWeatherIconUrl(String iconCode) {
    return "https://openweathermap.org/img/wn/$iconCode@2x.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Forecast")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      hintText: "Enter city name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    fetchForecast(cityController.text.trim());
                  },
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weather Cards
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isError
                      ? const Center(
                          child: Text(
                            "Failed to load weather data. Please try again.",
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        )
                      : !hasSearched
                          ? const Center(
                              child: Text("Search a city to get forecast."),
                            )
                          : forecastData.isEmpty
                              ? const Center(child: Text("No forecast data available."))
                              : ListView.builder(
                                  itemCount: forecastData.length,
                                  itemBuilder: (context, index) {
                                    final item = forecastData[index];
                                    final date = item['dt_txt'].split(' ')[0];
                                    final temp = item['main']['temp'];
                                    final condition = item['weather'][0]['main'];
                                    final iconCode = item['weather'][0]['icon'];

                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      child: ListTile(
                                        leading: Image.network(
                                          getWeatherIconUrl(iconCode),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                        ),
                                        title: Text(
                                          date,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(condition),
                                        trailing: Text(
                                          "$temp°C",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
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
