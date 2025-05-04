import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'password_reset_screen.dart';
import 'login_screen.dart';
import 'my_appointments_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profilim")),
        body: Center(child: Text("Lütfen tekrar giriş yapınız.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profilim"),
        backgroundColor: Colors.purple.shade300,
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          // Profil resmi
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple.shade200,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          SizedBox(height: 16),

          // Kullanıcı e-posta
          Center(
            child: Text(
              user.email!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),

          SizedBox(height: 30),
          Divider(),

          // Menü seçenekleri
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            text: "Randevularım",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyAppointmentsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.lock,
            text: "Şifreyi Güncelle",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PasswordResetScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            text: "Çıkış Yap",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(text),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
