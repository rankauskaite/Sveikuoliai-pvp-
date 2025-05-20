import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/breathing_excercise.dart';
import 'package:sveikuoliai/screens/meditation.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class RelaxMenuScreen extends StatelessWidget {
  const RelaxMenuScreen({super.key});

  void _showStressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Patiri stresą ar pyktį?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Šie patarimai tau gali padėti:'),
              SizedBox(height: 10),
              _buildAdviceCard(
                  '1. Pasirink didelį, dviženklį ar net triženkli skaičių ir skaičiuok atbulomis.'),
              _buildAdviceCard('2. Giliai įkvėpk ir iškvėpk kelis kartus.'),
              _buildAdviceCard(
                  '3. Skirk laiko meditacijai arba pasivaikščiojimui.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Uždaryti dialogą
              },
              child: Text('Uždaryti'),
            ),
          ],
        );
      },
    );
  }

  // Funkcija, kuri sugeneruoja patarimo kortelę
  Widget _buildAdviceCard(String adviceText) {
    return Container(
      margin: EdgeInsets.only(bottom: 10), // Tarpai tarp kortelių
      padding: EdgeInsets.all(15), // Padidintas užpildymas
      decoration: BoxDecoration(
        color: Colors.pink.shade50, // Fono spalva
        borderRadius: BorderRadius.circular(10), // Užapvalinti kampai
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        adviceText,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fiksuoti tarpai
    const double topPadding = 25.0; // Tarpas nuo viršaus
    const double horizontalPadding = 20.0; // Tarpai iš šonų
    const double bottomPadding =
        20.0; // Tarpas nuo apačios (virš BottomNavigation)

    // Gauname ekrano matmenis
    //final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: topPadding),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            _showStressDialog(
                                context); // Užkrovimas pop-out lango
                          },
                          icon: Icon(
                            Icons.add_alert, // Galite pasirinkti kitą ikoną
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Atsipalaiduok',
                      style: TextStyle(fontSize: 35),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Pasirink nusiraminimo būdą',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                            const Text(
                              'arba peržiūrėk pasiūlymus viršuje',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildBlock(
                      context: context,
                      title: 'Kvėpavimo\npratimai',
                      icon: Icons.air,
                      color: Colors.deepPurple.shade50,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BreathingExcerciseScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildBlock(
                      context: context,
                      title: 'Meditacija',
                      icon: Icons.self_improvement,
                      color: Colors.pink.shade50,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MeditationScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildBlock(
                      context: context,
                      title: 'Mankšta',
                      icon: Icons.fitness_center,
                      color: Colors.blue.shade50,
                      onTap: () {
                        // Čia galima pridėti navigaciją į mankštos ekraną
                      },
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(),
            SizedBox(
              height: bottomPadding,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 24, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
