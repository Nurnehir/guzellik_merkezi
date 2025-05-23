import 'package:flutter/material.dart';
import 'package:guzellik_merkezi/oneri_screen.dart'; // LatLng importu ekliyoruz

class TirnakScreen extends StatelessWidget {
  final List<String> kategoriler = [
    "Manikür",
    "Pedikür",
    "Jel Tırnak",
    "Protez Tırnak",
    "Güçlendirme",
    "Kalıcı Oje",
    "Nail Art",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tırnak Hizmetleri")),
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
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: kategoriler.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kategoriler[index],
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  OneriScreen(category: "Güzellik Merkezi"),
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
                      Icons.navigation_outlined, // Eğik boş konum simgesi
                      color: Colors.purple, // Mor renk
                      size: 30,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
