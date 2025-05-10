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
        SnackBar(content: Text("Lütfen puan verin ve yorum yazın.")),
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
      SnackBar(content: Text("Yorumunuz kaydedildi. Teşekkür ederiz.")),
    );

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("${widget.salonName} için Değerlendirme"),
        backgroundColor: Colors.purple.shade300,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : alreadyCommented
              ? Center(
                child: Text(
                  "Bu salon için daha önce yorum yaptınız.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text("Puanınız:", style: TextStyle(fontSize: 18)),
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
                    SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Yorumunuzu yazın...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: submitComment,
                        child: Text("Gönder"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
