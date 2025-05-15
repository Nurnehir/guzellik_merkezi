import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentScreen extends StatefulWidget {
  final String salonId;
  final String salonName;
  final String userName;
  final String userSurname;

  CommentScreen({
    required this.salonId,
    required this.salonName,
    required this.userName,
    required this.userSurname,
  });

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  int selectedRating = 0;
  TextEditingController commentController = TextEditingController();
  bool alreadyCommented = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkIfAlreadyCommented();
  }

  void checkIfAlreadyCommented() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('comments')
            .where('kullaniciAdi', isEqualTo: currentUser?.email)
            .where('salonId', isEqualTo: widget.salonId)
            .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        alreadyCommented = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void submitComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (selectedRating == 0 || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen puan verin ve yorum yazın.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("comments").add({
      'salonId': widget.salonId,
      'salonAdi': widget.salonName,
      'userName': widget.userName,
      'userSurname': widget.userSurname,
      'kullaniciAdi': currentUser?.email ?? '',
      'puan': selectedRating,
      'yorum': commentController.text.trim(),
      'tarih': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Yorumunuz kaydedildi. Teşekkür ederiz.")),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFADADD), Color(0xFFEAF6FF), Color(0xFFB3E5FC)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : alreadyCommented
                  ? const Center(
                    child: Text(
                      "❗ Bu salon için daha önce yorum yaptınız. ❗",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // 🔙 Geri butonu
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),

                        // 🎯 Başlık ortada ve aşağıda
                        const SizedBox(height: 30),
                        Text(
                          "${widget.salonName} için\nDeğerlendirme Yapın",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ⭐ Yorum ve puanlama kutusu
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Puanınız:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  final starIndex = index + 1;
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedRating = starIndex;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.star,
                                      color:
                                          selectedRating >= starIndex
                                              ? Colors.orange
                                              : Colors.grey,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: commentController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: "Yorumunuzu yazın...",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.pinkAccent,
                                        Colors.deepPurpleAccent,
                                        Colors.blueAccent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: submitComment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Gönder",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
