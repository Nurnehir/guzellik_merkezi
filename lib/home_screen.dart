import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Ekran"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hoş geldiniz!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildCategoryCard(
                    context,
                    icon: Icons.content_cut,
                    label: 'Kuaför',
                    color: Colors.pink[100]!,
                    onTap: () {
                      // TODO: Kuaför ekranına yönlendir
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.healing,
                    label: 'Mezoterapi',
                    color: Colors.purple[100]!,
                    onTap: () {
                      // TODO: Mezoterapi ekranına yönlendir
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.spa, // Tırnak ekranı için geçici ikon

                    label: 'Tırnak',
                    color: Colors.blue[100]!,
                    onTap: () {
                      // TODO: Tırnak ekranına yönlendir
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.face_retouching_natural,
                    label: 'Estetik',
                    color: Colors.green[100]!,
                    onTap: () {
                      // TODO: Estetik ekranına yönlendir
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black54),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
