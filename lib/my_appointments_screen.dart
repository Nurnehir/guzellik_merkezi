import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'randevu_al_page.dart';
import 'package:intl/intl.dart';
import 'comment_screen.dart';

class MyAppointmentsScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.email == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Randevularım")),
        body: Center(child: Text("Lütfen tekrar giriş yapınız.")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          "Randevularım",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFADADD), // Sol alt pembe
              Color(0xFFEAF6FF), // Orta geçiş
              Color(0xFFB3E5FC), // Sağ üst açık mavi
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userEmail', isEqualTo: user!.email)
                  .orderBy('appointmentDate')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Veri alınamadı: ${snapshot.error}"));
            }

            final appointments = snapshot.data?.docs ?? [];

            if (appointments.isEmpty) {
              return const Center(
                child: Text(
                  "Henüz bir randevunuz yok.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final doc = appointments[index];
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['appointmentDate'] as Timestamp).toDate();
                final formattedDate = DateFormat(
                  'dd MMM yyyy - HH:mm',
                  'tr_TR',
                ).format(date);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.deepPurple.shade100,
                      width: 1.3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(
                        data['salonName'] ?? "Salon",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Tarih: $formattedDate"),
                          Text("Hizmet: ${data['service']}"),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.hourglass_top,
                                color: Colors.orange.shade800,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                // 👈 Eklendi: metin satıra sığamazsa taşma yapmaz
                                child: Text(
                                  data['status'] == 'approved'
                                      ? "Randevunuz onaylandı"
                                      : data['status'] == 'rejected'
                                      ? "Randevunuz reddedildi"
                                      : "Onay bekleniyor",
                                  style: TextStyle(
                                    color:
                                        data['status'] == 'approved'
                                            ? Colors.green.shade700
                                            : data['status'] == 'rejected'
                                            ? Colors.red.shade700
                                            : Colors.orange.shade800,
                                    fontWeight:
                                        data['status'] == 'approved' ||
                                                data['status'] == 'rejected'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontStyle:
                                        data['status'] == null
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 0,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.orange),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CommentScreen(
                                        salonId: data['salonId'],
                                        salonName: data['salonName'],
                                        userName: data['userName'] ?? '',
                                        userSurname: data['userSurname'] ?? '',
                                        salonKategori:
                                            data['salonCategory'] ?? '',
                                        sehir: data['sehir'] ?? '',
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => RandevuAlPage(
                                        salonData: {
                                          'id': data['salonId'],
                                          'name': data['salonName'],
                                          'address': data['salonAddress'] ?? '',
                                          'category':
                                              data['salonCategory'] ?? '',
                                          'service': data['service'] ?? '',
                                        },
                                        existingAppointmentId: doc.id,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(doc.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
