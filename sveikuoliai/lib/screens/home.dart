import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/notification_model.dart';
import 'package:sveikuoliai/screens/garden.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/notification_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';
import 'package:sveikuoliai/services/notification_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AppNotificationService _notificationService =
      AppNotificationService(); // Pridėjome pranešimų paslaugą
  bool showNotifications = false; // Ar rodyti pranešimų panelę?
  List<AppNotification> notifications = []; // Pranešimų sąrašas
  String userName = "";
  String userUsername = "";
  final PageController _adController = PageController();
  final List<String> _reklamos = [
    'assets/images/reklamos/drouglas.png',
    'assets/images/reklamos/ebatelis.png',
    'assets/images/reklamos/vienaragis.png',
  ];
  int _reklamosIndex = 0;
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    _fetchSessionUser(); // Kviečiame užkrauti sesijos duomenis
    final now = DateTime.now();
  final trigger = now.add(const Duration(seconds: 10));
  NotificationHelper.scheduleDailyNotification(
    id: 999,
    title: 'Primename!',
    body: 'Nenusimink – tikslai formuojasi kasdien 🌱',
    hour: trigger.hour,
    minute: trigger.minute,
  );
  print("🔔 Notification planned for ${trigger.hour}:${trigger.minute}");

    _adTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        _reklamosIndex++;
        if (_reklamosIndex >= _reklamos.length) _reklamosIndex = 0;
        if (_adController.hasClients) {
          _adController.animateToPage(
            _reklamosIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    super.dispose();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchSessionUser() async {
    // Patikrinti, ar sesijoje jau yra duomenų
    if (userName.isEmpty || userUsername.isEmpty) {
      try {
        Map<String, String?> sessionData = await _authService.getSessionUser();
        setState(() {
          userName = sessionData['name'] ?? "Nežinomas";
          userUsername = sessionData['username'] ?? "Nežinomas";
        });
        _fetchUserNotifications(userUsername);
      } catch (e) {
        setState(() {
          userName = "Klaida gaunant duomenis";
        });
      }
    }
  }

  // Funkcija, kuri gauna vartotojo pranešimus iš Firestore
  Future<void> _fetchUserNotifications(String username) async {
    try {
      List<AppNotification> userNotifications =
          await _notificationService.getUserNotifications(username);
      setState(() {
        notifications = userNotifications;
      });
    } catch (e) {
      print("Klaida gaunant pranešimus: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        backgroundColor: const Color(0xFF8093F1),
      ),
      body: Stack(
        children: [
          Center(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ProfileButton(),
                          Container(
                            height: 50,
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              userName, // Čia bus rodoma naudotojo vardas
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showNotifications = true;
                              });
                            },
                            icon: const Icon(Icons.notifications_outlined,
                                size: 35),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GardenScreen()),
                              );
                            },
                            child: Text(
                              'Mano augalai',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.blue, // Paryškinti kaip nuorodą
                                decoration: TextDecoration
                                    .underline, // Pabraukta kaip tikra nuoroda
                              ),
                            ),
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPlantColumn('Orchidėja',
                                imageUrl:
                                    'assets/images/augalai/orchideja/16.png'),
                            _buildPlantColumn('Dobilas',
                                imageUrl:
                                    'assets/images/augalai/dobiliukas/4.png'),
                            _buildPlantColumn('Žibuoklės',
                                imageUrl:
                                    'assets/images/augalai/zibuokle/8.png'),
                            _buildPlantColumn('Ramunė',
                                imageUrl:
                                    'assets/images/augalai/ramuneles/6.png'),
                            _buildPlantColumn('Gervuogė',
                                imageUrl:
                                    'assets/images/augalai/gervuoge/24.png'),
                            _buildPlantColumn('Saulėgrąža',
                                imageUrl:
                                    'assets/images/augalai/saulegraza/12.png'),
                            _buildPlantColumn('Vyšnia',
                                imageUrl:
                                    'assets/images/augalai/vysnia/36.png'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 150,
                            color: const Color(0xFFB388EB),
                            child: Image.asset(
                              'assets/gif/premium.gif',
                              fit: BoxFit.cover, // Kad užpildytų visą plotą
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PageView.builder(
                              controller: _adController,
                              itemCount: _reklamos.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    _reklamos[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const BottomNavigation(),
              ],
            ),
          ),
          // Išslenkanti pranešimų panelė
          if (showNotifications)
            GestureDetector(
              onTap: () {
                setState(() {
                  showNotifications = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3), // Permatomas fonas
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 300,
                    height: double.infinity,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBar(
                          title: const Text('Pranešimai'),
                          backgroundColor: const Color(0xFF8093F1),
                          automaticallyImplyLeading: false,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  showNotifications = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              bool isUnread = !notifications[index].isRead;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Žymime, kad pranešimas perskaitytas
                                    if (isUnread) {
                                      _notificationService
                                          .markNotificationAsRead(
                                              notifications[index].id);
                                    }
                                  });
                                  _showMessageDialog(notifications[index].text);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? const Color(
                                            0xFFFFC0CB) // Neperskaityti pranešimai
                                        : const Color(0xFF8093F1)
                                            .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(15),
                                    border: isUnread
                                        ? Border.all(
                                            color: Colors.pink, width: 2)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications,
                                          color: isUnread
                                              ? Colors.pink
                                              : Colors.deepPurple,
                                          size: 24),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          notifications[index].text,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlantColumn(String plantName, {String? imageUrl}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        imageUrl != null && imageUrl.isNotEmpty
            ? Image.asset(imageUrl, width: 90, height: 90)
            : const Icon(Icons.circle, size: 90, color: Color(0xFFD9D9D9)),
        Text(plantName, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Pranešimas',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Uždaryti',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}
