import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/friends.dart';
import 'package:sveikuoliai/screens/hello.dart';
import 'package:sveikuoliai/screens/home.dart';
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
  String userVersion = "Gija NULIS";
  String userIcon = 'account_circle';

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
          userIcon = sessionData['icon']?.isNotEmpty == true
              ? sessionData['icon']!
              : 'account_circle';
        },
      );
      UserModel? userData = await _userService.getUserEntry(userUsername);
      setState(() {
        //userIcon = userData!.iconUrl!;
        userJoinDate = userData!.createdAt;
        if (userData.version == "premium") {
          userVersion = "Gija PLIUS";
        }
        if (userData.version == "free") {
          userVersion = "Gija NULIS";
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen()), // Pakeiskite į jūsų prisijungimo ekraną
                            );
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
                                  builder: (context) => UpdateProfileScreen(
                                        version: userVersion,
                                      )),
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
                        Center(
                          child: userIcon == 'account_circle'
                              ? const Icon(
                                  Icons.account_circle,
                                  size: 250,
                                  color: Color(0xFFD9D9D9),
                                )
                              : Image.asset(
                                  userIcon,
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
                                    fontSize: 30, fontWeight: FontWeight.bold),
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
                                    fontSize: 15, color: Color(0xFF8093F1)),
                              ),
                            ],
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
                                style: TextStyle(
                                    fontSize: 15, color: Color(0xFF8093F1)),
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          if (userVersion == 'Gija PLIUS') ...[
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
                                iconColor:
                                    const Color(0xFF8093F1), // Violetinė spalva
                              ),
                              child: const Text(
                                'Draugai',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ] else ...[
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                iconColor:
                                    const Color(0xFF8093F1), // Violetinė spalva
                              ),
                              child: const Text(
                                'Draugų funkcija - Gija PLIUS',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const BottomNavigation(), // Įterpiama navigacija
            SizedBox(
              height: bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}
