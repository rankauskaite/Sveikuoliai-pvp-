import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/hello.dart';
import 'package:sveikuoliai/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pagrindinis ekranas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthCheckScreen(), // Tikriname prisijungimo būseną
    );
  }
}

// Kol kas išjungta tikrinimo logika, bet čia reikės prisijungimo patikrinimo
class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = false; // Čia vėliau bus tikrinama prisijungimo būsena

    return isLoggedIn ? const HomeScreen() : HelloScreen();
  }
}
