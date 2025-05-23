import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guzellik_merkezi/map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneriScreen extends StatefulWidget {
  final String category;

  const OneriScreen({super.key, required this.category});

  @override
  State<OneriScreen> createState() => _OneriScreenState();
}

class _OneriScreenState extends State<OneriScreen> {
  List<Map<String, dynamic>> salonlar = [];
  bool yukleniyor = true;

  final renkler = [
    [Color(0xffefafaf), Color(0xffffc1c1)],
    [Color(0xffab47bc), Color(0xff8e24aa)],
    [Color(0xff9c9ad7), Color(0xff9cb2c5)],
    [Color(0xfffc6161), Color(0xfffd6e6e)],
    [Color(0xffffc1c1), Color(0xffffdddd)],
  ];

  @override
  void initState() {
    super.initState();
    fetchAIRecommendedSalons();
  }

  Future<void> fetchAIRecommendedSalons() async {
    try {
      final yorumSnapshot =
          await FirebaseFirestore.instance.collection('comments').get();

      Map<String, List<double>> puanlar = {};
      for (var doc in yorumSnapshot.docs) {
        final salonAdi = doc['salonAdi'];
        final puan = (doc['puan'] as num?)?.toDouble() ?? 0.0;
        puanlar.putIfAbsent(salonAdi, () => []).add(puan);
      }

      final yorumlar =
          puanlar.entries.map((e) {
            final ortalama = e.value.reduce((a, b) => a + b) / e.value.length;
            return {
              'salonAdi': e.key,
              'puan': double.parse(ortalama.toStringAsFixed(2)),
            };
          }).toList();

      print("Yorumlardan hesaplanan puanlar:");
      for (var y in yorumlar) {
        print("${y['salonAdi']} - ${y['puan']}");
      }

      final response = await http.post(
        Uri.parse(
          'https://us-central1-beautysalonapp-4c3af.cloudfunctions.net/api/gemini',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'yorumlar': yorumlar}),
      );

      print("Gemini yanıtı (response.body): ${response.body}");

      final decoded = jsonDecode(response.body);
      final sonucText = decoded['sonuc'] ?? '';

      print("Gemini sonucText:");
      print(sonucText);
      final satirlar =
          sonucText
              .split(RegExp(r'\n|(?=\d+\.)'))
              .where((s) => s != null && s.toString().trim().isNotEmpty)
              .map((s) => s.toString().trim())
              .toList();

      final salonAdlari =
          satirlar
              .map((s) {
                final match = RegExp(
                  r'^\d+\.\s*(.*?)\s*-\s*Ortalama Puan:',
                ).firstMatch(s);
                return match?.group(1)?.trim();
              })
              .whereType<String>()
              .toList();

      print("Gemini'den çıkarılan salon adları:");
      salonAdlari.forEach(print);

      final salonSnapshot =
          await FirebaseFirestore.instance.collection('salons').get();
      final tumSalonlar =
          salonSnapshot.docs.map((doc) {
            final data = doc.data();
            return {...data, 'salonId': doc.id};
          }).toList();

      final sonuc = <Map<String, dynamic>>[];

      for (var ad in salonAdlari) {
        final matchedList =
            tumSalonlar.where((s) {
              final name = s['name']?.toString().toLowerCase() ?? '';
              return name.contains(ad.toLowerCase());
            }).toList();

        if (matchedList.isNotEmpty) {
          final matched = matchedList.first;
          final matchedName = matched['name'].toString().toLowerCase();

          final puanVerisi = yorumlar.firstWhere(
            (y) =>
                y['salonAdi'].toString().toLowerCase() == matchedName ||
                matchedName.contains(y['salonAdi'].toString().toLowerCase()),
            orElse: () => {'puan': 'undefined'},
          );
          matched['puan'] = puanVerisi['puan'] ?? 'undefined';
          print(
            "E\u015fle\u015fen salon: ${matched['name']} - Puan: ${matched['puan']}",
          );
          sonuc.add(matched);
        } else {
          print("E\u015eLE\u015eME YOK: $ad");
        }
      }

      setState(() {
        salonlar = sonuc;
        yukleniyor = false;
      });
    } catch (e, stackTrace) {
      print('Hata: $e');
      print('StackTrace: $stackTrace');
      setState(() => yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/arkaplan.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "🤖 Yapay Zeka Tabanlı Salon Önerisi",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff90caf9),
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                yukleniyor
                    ? const CircularProgressIndicator()
                    : Expanded(
                      child: ListView.builder(
                        itemCount: salonlar.length,
                        itemBuilder: (context, index) {
                          final salon = salonlar[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: renkler[index % renkler.length],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 8),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${index + 1}. ${salon['name']}\nŞehir: ${salon['address']}\nOrtalama Puan: ${salon['puan']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MapScreen(
                                              category: salon['category'],
                                              cityCoordinates: LatLng(
                                                salon['latitude'],
                                                salon['longitude'],
                                              ),
                                              selectedSalon:
                                                  salon, // ✅ BU SATIRI EKLE
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.pin_drop,
                                    color: Colors.red,
                                  ),
                                  label: const Text("Git"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MapScreen(
                              category: widget.category,
                              cityCoordinates:
                                  salonlar.isNotEmpty
                                      ? LatLng(
                                        salonlar.first['latitude'],
                                        salonlar.first['longitude'],
                                      )
                                      : const LatLng(39.9208, 32.8541),
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7b61ff),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Haritaya Git",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
