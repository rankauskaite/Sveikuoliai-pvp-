import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/hello.dart';
import 'package:sveikuoliai/screens/settings.dart';
import 'package:sveikuoliai/screens/update_profile.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/services/auth_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService =
      UserService(); // Sukuriame UserService instanciją
  String userName = "";
  String userUsername = "";
  String userEmail = "Kraunama...";
  DateTime userJoinDate = DateTime.now();
  String userVersion = "nemokama";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(
        () {
          userName = sessionData['name'] ?? "Nežinomas";
          userUsername = sessionData['username'] ?? "Nežinomas";
          userEmail = sessionData['email'] ?? "Nežinomas";
        },
      );
      UserModel? userData = await _userService.getUserEntry(userUsername);
      setState(() {
        userJoinDate = userData?.createdAt ?? DateTime.now();
        if (userData?.version == "premium") {
          userVersion = "premium";
        }
      });
    } catch (e) {
      setState(() {
        userName = "Klaida gaunant duomenis";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
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
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UpdateProfileScreen(version: userVersion,)),
                          );
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 30,
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
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      // Centrinė account_circle ikona
                      Center(
                        child: const Icon(
                          Icons.account_circle,
                          size: 200,
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                      // Viršutinė dešinė logout ikona
                      Positioned(
                        top: 5, // Galite koreguoti atstumą nuo viršaus
                        right: 0, // Galite koreguoti atstumą nuo dešinės
                        child: IconButton(
                          onPressed: () async {
                            await _authService.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HelloScreen()), // Pakeiskite į jūsų prisijungimo ekraną
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userUsername,
                    style: TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mano duomenys',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'El. paštas',
                        style: TextStyle(fontSize: 12),
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
                          color: Color(0xFFB388EB),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFB388EB),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Registracijos data',
                        style: TextStyle(fontSize: 12),
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
                          color: Color(0xFFB388EB),
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
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        userVersion,
                        style:
                            TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FriendsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      iconColor: const Color(0xFF8093F1), // Violetinė spalva
                    ),
                    child: const Text(
                      'Draugai',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
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
