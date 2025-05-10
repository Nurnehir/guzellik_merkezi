import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListelemeScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.email == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Yorumlarım")),
        body: Center(child: Text("Lütfen tekrar giriş yapınız.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Yorumlarım"),
        backgroundColor: Colors.purple.shade300,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("comments")
                .where("kullaniciAdi", isEqualTo: user!.email)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu: ${snapshot.error}"));
          }

          final comments = snapshot.data?.docs ?? [];

          if (comments.isEmpty) {
            return Center(child: Text("Henüz yorum yapmadınız."));
          }

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final data = comments[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['salonAdi'] ?? "Salon",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Kullanıcı: ${data['userName'] ?? ''} ${data['userSurname'] ?? ''}",
                      ),
                      SizedBox(height: 6),
                      Text("Yorum: ${data['yorum'] ?? ''}"),
                      SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          data['puan'] ?? 0,
                          (i) => Icon(Icons.star, color: Colors.orange),
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
    );
  }
}
