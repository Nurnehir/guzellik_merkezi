import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          "Admin Paneli",
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFADADD), // Açık pembe (alt)
              Color(0xFFEAF6FF), // Beyazımsı orta
              Color(0xFFB3E5FC), // Açık mavi (üst)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const SizedBox(height: 12),
            SectionTitle("🗓 Randevular"),
            AppointmentList(),
            const SizedBox(height: 16),
            const Divider(thickness: 2),
            SectionTitle("⭐ Yorumlar"),
            CommentList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}

class AppointmentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final dateTime = data['appointmentDate']?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['userName']} ${data['userSurname']} - ${data['phone']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text("📍 ${data['salonName']} - ${data['salonAddress']}"),
                    if (dateTime != null)
                      Text(
                        "🗓 ${dateTime.day}.${dateTime.month}.${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
                      ),
                    Text("💇 Hizmet: ${data['service']}"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(doc.id)
                                .update({'status': 'approved'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Randevu onaylandı."),
                              ),
                            );
                          },
                          child: const Text(
                            "Onayla",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(doc.id)
                                .update({'status': 'rejected'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("❌ Randevu reddedildi."),
                              ),
                            );
                          },
                          child: const Text(
                            "Reddet",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey.shade700),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(doc.id)
                                .delete();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("🗑 Randevu silindi."),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CommentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('comments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  "${data['userName']} ${data['userSurname']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text("🏢 ${data['salonAdi']}"),
                    Text("⭐ Puan: ${data['puan']}"),
                    Text("💬 Yorum: ${data['yorum']}"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('comments')
                        .doc(doc.id)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Yorum silindi.")),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
