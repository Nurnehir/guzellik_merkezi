import 'package:flutter/material.dart';
import 'package:guzellik_merkezi/map_screen.dart'; // <-- MapScreen import'u
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng importu ekliyoruz

class CiltBakimiScreen extends StatelessWidget {
  final List<String> kategoriler = [
    "Klasik Cilt Bakımı",
    "Akne (Sivilce) Bakımı",
    "Leke Karşıtı Bakım",
    "Anti-aging Bakım (Yaşlanma Karşıtı)",
    "Hydrafacial Cilt Bakımı",
    "C vitamini Bakımı",
    "Nemlendirici Derin Bakım",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cilt Bakımı Hizmetleri")),
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
                              (context) => MapScreen(
                                category: "Güzellik Merkezi",
                                cityCoordinates: LatLng(
                                  0,
                                  0,
                                ), // Anlık konum alınacak
                              ),
                        ),
                      );
                    },
                    child: Text("Haritada Cilt Bakımı Hizmetlerini Göster"),
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
