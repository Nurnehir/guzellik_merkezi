import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'kuafor_screen.dart';
import 'tirnak_screen.dart';
import 'estetik_screen.dart';
import 'mezoterapi_screen.dart';
import 'lazer_screen.dart';
import 'cilt_bakimi_screen.dart';
import 'profile_screen.dart';
import 'listeleme_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  Duration _timeoutDuration = Duration(minutes: 5);

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(_timeoutDuration, _handleTimeout);
  }

  void _handleTimeout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      child: Scaffold(
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
                  children:
                      categories.map((category) {
                        return _buildCategoryCard(
                          context,
                          iconPath: category.iconPath,
                          label: category.name,
                          color: category.color,
                          onTap: () {
                            if (category.name == "Kuaför") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KuaforScreen(),
                                ),
                              );
                            } else if (category.name == "Tırnak") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TirnakScreen(),
                                ),
                              );
                            } else if (category.name == "Estetik") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EstetikScreen(),
                                ),
                              );
                            } else if (category.name == "Mezoterapi") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MezoterapiScreen(),
                                ),
                              );
                            } else if (category.name == "Lazer") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LazerScreen(),
                                ),
                              );
                            } else if (category.name == "Cilt Bakımı") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CiltBakimiScreen(),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "bilgi",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListelemeScreen()),
                );
              },
              backgroundColor: Colors.blue.shade100,
              child: ClipOval(
                child: Image.asset(
                  'assets/bilgi2.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              tooltip: "Yorumlarım",
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "profil",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.person, color: Colors.black87),
              tooltip: "Profilim",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String iconPath,
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
            Image.asset(
              iconPath,
              width: 50, // İconların boyutunu ayarlayabilirsiniz
              height: 50,
            ),
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

  final List<CategoryItem> categories = [
    CategoryItem("Kuaför", 'assets/kuafor.png', Colors.pink[100]!),
    CategoryItem("Tırnak", 'assets/tirnak.png', Colors.teal[100]!),
    CategoryItem("Estetik", 'assets/estetik.png', Colors.amber[100]!),
    CategoryItem(
      "Mezoterapi",
      'assets/mezoterapi.png',
      Colors.deepPurple[100]!,
    ),
    CategoryItem("Lazer", 'assets/lazer.png', Colors.blueGrey[100]!),
    CategoryItem("Cilt Bakımı", 'assets/cilt_bakimi.png', Colors.green[100]!),
  ];
}

class CategoryItem {
  final String name;
  final String iconPath;
  final Color color;

  CategoryItem(this.name, this.iconPath, this.color);
}
