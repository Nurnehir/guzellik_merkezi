import 'package:flutter/material.dart';
import 'package:guzellik_merkezi/map_screen.dart'; // <-- MapScreen import'u
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng importu

class LazerScreen extends StatelessWidget {
  final Map<String, List<String>> kategoriler = {
    "Buz Lazer": ["Yüz", "Kol", "Bacak", "Tüm Vücut"],
    "Alexandrite Lazer": ["Yüz", "Kol", "Bacak", "Tüm Vücut"],
    "Diod Lazer": ["Yüz", "Kol", "Bacak", "Tüm Vücut"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lazer Hizmetleri")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDEBEB),
              Color(0xFFE7DFFF),
              Color(0xFFDFFFE7),
              Color(0xFFFFE6F7),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children:
              kategoriler.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...entry.value.map((altKategori) {
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              altKategori,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => MapScreen(
                                        category: "Güzellik Merkezi",
                                        cityCoordinates: LatLng(0, 0),
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(14),
                              backgroundColor:
                                  Colors.lightBlue[100], // Açık mavi arka plan
                              elevation: 4,
                            ),
                            child: Icon(
                              Icons
                                  .navigation_outlined, // Eğik boş konum simgesi
                              color: Colors.purple, // Mor renk
                              size: 30,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 24),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
