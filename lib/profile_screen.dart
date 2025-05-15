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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFADADD), // Sol altta açık pembe
              Color(0xFFEAF6FF), // Ortalarda beyaz-mavi geçiş
              Color(0xFFB3E5FC), // Sağ üstte açık mavi
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Profilim",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 30),

                // 🔲 Orta Kutucuk (Card)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.purple.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.email!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildMenuItem(
                        context,
                        icon: Icons.calendar_today,
                        text: "Randevularım",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyAppointmentsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildMenuItem(
                        context,
                        icon: Icons.lock,
                        text: "Şifreyi Güncelle",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PasswordResetScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
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
                ),
              ],
            ),
          ),
        ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
