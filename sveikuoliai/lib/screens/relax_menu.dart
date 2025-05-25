import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/breathing_excercise.dart';
import 'package:sveikuoliai/screens/meditation.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class RelaxMenuScreen extends StatefulWidget {
  const RelaxMenuScreen({super.key});

  @override
  _RelaxMenuScreenState createState() => _RelaxMenuScreenState();
}

class _RelaxMenuScreenState extends State<RelaxMenuScreen> {
  final AuthService _authService = AuthService();
  bool isDarkMode = false; // Temos būsena

  void _showStressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Patiri stresą ar pyktį?',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Šie patarimai tau gali padėti:',
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
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
              child: Text(
                'Uždaryti',
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
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
        color: isDarkMode ? Colors.grey[800] : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        adviceText,
        style: TextStyle(
            fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
      });
    } catch (e) {
      if (mounted) {
        String message = 'Klaida gaunant duomenis ❌';
        showCustomSnackBar(context, message, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
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
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.white,
                    width: 20,
                  ),
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
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            _showStressDialog(context);
                          },
                          icon: Icon(
                            Icons.add_alert,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Atsipalaiduok',
                      style: TextStyle(
                        fontSize: 35,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Pasirink nusiraminimo būdą',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            Text(
                              'arba peržiūrėk pasiūlymus viršuje',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
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
                      color: isDarkMode
                          ? Colors.deepPurple.shade300
                          : Colors.deepPurple.shade50,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BreathingExcerciseScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildBlock(
                      context: context,
                      title: 'Meditacija',
                      icon: Icons.self_improvement,
                      color: isDarkMode
                          ? Colors.pink.shade200
                          : Colors.pink.shade50,
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
                      color: isDarkMode
                          ? Colors.blue.shade200
                          : Colors.blue.shade50,
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
              color: isDarkMode ? Colors.black54 : Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon,
                size: 40, color: isDarkMode ? Colors.white : Colors.deepPurple),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                  fontSize: 24,
                  color: isDarkMode ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
