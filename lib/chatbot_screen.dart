import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> mesajlar = [];
  final TextEditingController _controller = TextEditingController();
  bool _yukleniyor = false;

  final List<String> sabitSorular = [
    "İstanbul Kuaför",
    "İstanbul Güzellik Merkezi",
    "Ankara Kuaför",
    "Ankara Güzellik Merkezi",
    "İzmir Kuaför",
    "İzmir Güzellik Merkezi",
    "Bursa Kuaför",
    "Bursa Güzellik Merkezi",
    "Elazığ Kuaför",
    "Elazığ Güzellik Merkezi",
  ];

  Future<void> soruyuGonder(String mesaj) async {
    setState(() {
      mesajlar.add({"rol": "kullanici", "mesaj": mesaj});
      _yukleniyor = true;
    });

    final url = Uri.parse(
      "https://us-central1-beautysalonapp-4c3af.cloudfunctions.net/api/chatbot",
    );
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mesaj": mesaj}),
    );

    final json = jsonDecode(response.body);
    final yanit = json["yanit"] ?? "Bir yanıt alınamadı.";

    setState(() {
      mesajlar.add({"rol": "bot", "mesaj": yanit});
      _yukleniyor = false;
    });
  }

  Widget mesajBaloncugu(String text, bool kullanici) {
    return Align(
      alignment: kullanici ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:
              kullanici
                  ? const Color.fromARGB(255, 95, 194, 255)
                  : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                kullanici
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
            bottomRight:
                kullanici
                    ? const Radius.circular(0)
                    : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: kullanici ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget sabitSoruButon(String soru) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: OutlinedButton(
        onPressed: () {
          final bolumler = soru.split(" ");
          final sehir = bolumler[0];
          final kategori = bolumler.sublist(1).join(" ");
          final tamSoru =
              "${sehir.toLowerCase().replaceAll("’", "'")}'da en iyi ${kategori.toLowerCase()} hangisi?";

          soruyuGonder(tamSoru);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          soru,
          style: const TextStyle(fontSize: 13, color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text("Güzellik Danışmanı"),
        backgroundColor: const Color.fromARGB(255, 70, 175, 250),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: sabitSorular.map(sabitSoruButon).toList(),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: mesajlar.length,
                  itemBuilder: (context, index) {
                    final msg = mesajlar[index];
                    return mesajBaloncugu(
                      msg["mesaj"]!,
                      msg["rol"] == "kullanici",
                    );
                  },
                ),
              ),
              if (_yukleniyor)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 66, 174, 250), // aynı mavi ton
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Sorunuzu yazın...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 62, 171, 249),
                    ), // Açık mavi ton

                    onPressed: () {
                      final mesaj = _controller.text.trim();
                      if (mesaj.isNotEmpty) {
                        _controller.clear();
                        soruyuGonder(mesaj);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
