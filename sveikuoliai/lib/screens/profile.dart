import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/hello.dart';
import 'package:sveikuoliai/screens/home.dart';
import 'package:sveikuoliai/screens/settings.dart';
import 'package:sveikuoliai/screens/update_profile.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/services/auth_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String userName = "";
  String userUsername = "";
  String userEmail = "Kraunama...";
  DateTime userJoinDate = DateTime.now();
  String userVersion = "Gija NULIS";
  String userIcon = 'account_circle';
  String iconUrl = 'account_circle'; // Naujas kintamasis tik failo pavadinimui
  bool isDarkMode = false; // Temos būsena

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
        userName = sessionData['name'] ?? "Nežinomas";
        userUsername = sessionData['username'] ?? "Nežinomas";
        userEmail = sessionData['email'] ?? "Nežinomas";
        userIcon = sessionData['icon']?.isNotEmpty == true
            ? sessionData['icon']!
            : 'account_circle';
        iconUrl = userIcon.contains('/') ? userIcon.split('/').last : userIcon;
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
        userVersion = sessionData['version'] ?? 'free';
      });
    } catch (e) {
      setState(() {
        userName = "Klaida gaunant duomenis";
      });
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
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateProfileScreen(
                                  version: userVersion,
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Center(
                          child: userIcon == 'account_circle'
                              ? Icon(
                                  Icons.account_circle,
                                  size: 250,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : const Color(0xFFD9D9D9),
                                )
                              : Image.asset(
                                  'assets/images/avataraiHigh/$iconUrl',
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 5,
                          right: 0,
                          child: IconButton(
                            onPressed: () async {
                              await _authService.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HelloScreen()),
                              );
                            },
                            icon: Icon(
                              Icons.logout,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userUsername,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFF8093F1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Mano duomenys',
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'El. paštas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFFB388EB),
                                  decoration: TextDecoration.underline,
                                  decorationColor: isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFFB388EB),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Registracijos data',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                userJoinDate.toString().substring(0, 10),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFFB388EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Versija: ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                userVersion,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFF8093F1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          if (userVersion == 'premium') ...[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FriendsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                'Draugai',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ] else ...[
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                'Draugų funkcija - Gija PLIUS',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BottomNavigation(),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}
