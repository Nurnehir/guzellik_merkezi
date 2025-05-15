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
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ana Ekran",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Hoş geldiniz!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children:
                            categories.map((category) {
                              return _buildCategoryCard(
                                iconPath: category.iconPath,
                                label: category.name,
                                color: category.color,
                                onTap: () {
                                  switch (category.name) {
                                    case "Kuaför":
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => KuaforScreen(),
                                        ),
                                      );
                                      break;
                                    case "Tırnak":
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TirnakScreen(),
                                        ),
                                      );
                                      break;
                                    case "Estetik":
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EstetikScreen(),
                                        ),
                                      );
                                      break;
                                    case "Mezoterapi":
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MezoterapiScreen(),
                                        ),
                                      );
                                      break;
                                    case "Lazer":
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LazerScreen(),
                                        ),
                                      );
                                      break;
                                    case "Cilt Bakımı":
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CiltBakimiScreen(),
                                        ),
                                      );
                                      break;
                                  }
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Sağ üst köşedeki logout iconu
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/logout.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),

              // Sol alttaki bilgi2.png (Yorumlarım) - ŞEFFAF & YUVARLAK
              Positioned(
                bottom: 20,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ListelemeScreen()),
                    );
                  },
                  child: ClipOval(
                    child: Image.asset(
                      'assets/bilgi2.png',
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Sağ alttaki profil butonu
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.shade100,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
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
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 50, height: 50),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
