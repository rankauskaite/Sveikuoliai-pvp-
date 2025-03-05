import 'package:flutter/material.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'screens/profile.dart';

void main() {
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 320,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 20),
              ),
              child: Column(
                children: [
                  // Row, kad visi elementai būtų vienoje eilutėje
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Išlaikyti kairę, galite keisti į 'center' ar 'end'
                    children: [
                      IconButton(
                        icon: const Icon(Icons.account_circle, size: 60),
                        color: const Color(0xFFD9D9D9),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                          );
                        },
                      ),
                      Container(
                        height:
                            50, // Nustatome aukštį, kad tekstas būtų apačioje
                        alignment: Alignment
                            .bottomLeft, // Užtikrina, kad tekstas bus apačioje
                        child: const Text(
                          'VARDAS',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      const Icon(Icons.notifications_outlined, size: 35),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mano augalai',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centruojame elementus vertikaliai
                        children: const [
                          Icon(
                            Icons.circle,
                            size: 90,
                            color: Color(0xFFD9D9D9),
                          ),
                          Text(
                            'Orchidėja',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.circle,
                            size: 90,
                            color: Color(0xFFD9D9D9),
                          ),
                          Text(
                            'Dobilas',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.circle,
                            size: 90,
                            color: Color(0xFFD9D9D9),
                          ),
                          Text(
                            'Žibuoklės',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centruoti horizontaliai
                    children: [
                      Container(
                        width: 250, // Nustatykite plotį
                        height: 150, // Nustatykite aukštį
                        color: const Color(0xFFB388EB), // Spalva
                        child: Text(
                          'PREMIUM VERSIJOS REKLAMA',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centruoti horizontaliai
                    children: [
                      Container(
                        width: 250, // Nustatykite plotį
                        height: 100, // Nustatykite aukštį
                        color: const Color(0xFFD9D9D9), // Spalva
                        child: Text(
                          'Reklamos plotas',
                          style: TextStyle(
                            fontSize: 37,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const BottomNavigation(), // Įterpiama navigacija
          ],
        ),
      ),
    );
  }
}
