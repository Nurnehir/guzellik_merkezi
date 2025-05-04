import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'randevu_al_page.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(title: Text("Randevularım")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('appointments')
                .where('userEmail', isEqualTo: user!.email)
                .orderBy('appointmentDate')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Veri alınamadı: ${snapshot.error}"));
          }

          final appointments = snapshot.data?.docs ?? [];

          if (appointments.isEmpty) {
            return Center(child: Text("Henüz bir randevunuz yok."));
          }

          return ListView.builder(
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
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(data['salonName'] ?? "Salon"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tarih: $formattedDate"),
                      Text("Hizmet: ${data['service']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
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
                                      'category': data['salonCategory'] ?? '',
                                      'service': data['service'] ?? '',
                                    },
                                    existingAppointmentId: doc.id,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
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
              );
            },
          );
        },
      ),
    );
  }
}
