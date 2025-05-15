import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectCityScreen extends StatefulWidget {
  @override
  _SelectCityScreenState createState() => _SelectCityScreenState();
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  String? selectedCity;

  final List<String> cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Elazığ',
  ];

  final Map<String, LatLng> cityCoordinates = {
    'İstanbul': LatLng(41.015137, 28.979530),
    'Ankara': LatLng(39.9334, 32.8597),
    'İzmir': LatLng(38.4192, 27.1287),
    'Bursa': LatLng(40.1897, 29.0691),
    'Elazığ': LatLng(38.6801, 39.2262),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFADADD), // Açık pembe alt
              Color(0xFFEAF6FF), // Beyazımsı geçiş
              Color(0xFFB3E5FC), // Açık mavi üst
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Şehir Seçin",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCity,
                        hint: const Text("Bir şehir seçin"),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCity = newValue;
                          });
                        },
                        items:
                            cities.map((String city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          selectedCity != null
                              ? () {
                                Navigator.pop(
                                  context,
                                  cityCoordinates[selectedCity!],
                                );
                              }
                              : null,
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text(
                        "Haritada Göster",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
