import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    determineInitialScreen();
  }

  Future<void> determineInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _initialScreen = LoginScreen();
      });
    } else {
      // Son giriş zamanını kontrol et
      final lastSignIn = user.metadata.lastSignInTime;
      final now = DateTime.now();

      if (lastSignIn != null && now.difference(lastSignIn).inMinutes <= 5) {
        _initialScreen = HomeScreen(); // 5 dakika içinde giriş yapılmış
      } else {
        await FirebaseAuth.instance.signOut(); // Oturumu sonlandır
        _initialScreen = LoginScreen(); // Yeniden giriş isteniyor
      }

      setState(() {}); // Durumu güncelle
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Güzellik Merkezi',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Roboto'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      home:
          _initialScreen ??
          Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
