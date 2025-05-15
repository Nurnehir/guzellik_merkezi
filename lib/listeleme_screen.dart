import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListelemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Yorum ve Değerlendirmeler"),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: Text("Lütfen tekrar giriş yapınız.")),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFADADD), // Açık pembe
              Color(0xFFEAF6FF), // Beyazımsı açık geçiş
              Color(0xFFB3E5FC), // Açık mavi
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Yorum ve Değerlendirmeler",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("comments")
                          .where("kullaniciAdi", isEqualTo: user.email)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Hata oluştu: ${snapshot.error}"),
                      );
                    }

                    final comments = snapshot.data?.docs ?? [];

                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          "Henüz yorum yapmadınız.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final data =
                            comments[index].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['salonAdi'] ?? "Salon",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "👤 ${data['userName'] ?? ''} ${data['userSurname'] ?? ''}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "💬 ${data['yorum'] ?? ''}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: List.generate(
                                    (data['puan'] ?? 0).toInt(),
                                    (i) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
