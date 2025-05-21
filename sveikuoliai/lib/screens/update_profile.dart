import 'package:flutter/material.dart';
import 'package:sveikuoliai/screens/profile.dart';
import 'package:sveikuoliai/screens/version.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'dart:ui';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String version;
  const UpdateProfileScreen({Key? key, required this.version})
      : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService =
      UserService(); // Sukuriame UserService instanciją
  String userUsername = "";
  String userName = "";
  String userEmail = "";
  String userVersion = "";
  String selectedIconName = 'account_circle'; // numatytoji

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();

  final Map<String, IconData> availableIcons = {
    'account_circle': Icons.account_circle,
    'face': Icons.face,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'pets': Icons.pets,
    'emoji_emotions': Icons.emoji_emotions,
    'local_florist': Icons.local_florist,
    'ac_unit': Icons.ac_unit,
    'cruelty_free': Icons.cruelty_free
  };

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
        userUsername = sessionData['username'] ?? "Nežinomas";
        userName = sessionData['name'] ?? "Nežinomas";
        userEmail = sessionData['email'] ?? "Nežinomas";
        userVersion = sessionData['version'] ?? "Nežinomas";

        _userNameController.text =
            userName; // Priskiriame gautus duomenis į TextEditingController
        _userEmailController.text = userEmail;
      });
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  // Funkcija, kad išsaugoti vartotojo duomenis
  Future<void> _saveUserData() async {
    try {
      String newName = _userNameController.text;
      String newEmail = _userEmailController.text;
      String newVersion = userVersion;
      String newIcon = selectedIconName;

      // Atnaujiname vartotojo duomenis paslaugos pagalba
      await _userService.updateUserData(
          userUsername, newName, newEmail, newVersion, newIcon);
      _authService.updateUserSession('name', newName);
      _authService.updateUserSession('email', newEmail);
      _authService.updateUserSession('version', newVersion);

      // Atvaizduojame sėkmės pranešimą
      String successMessage = 'Duomenys sėkmingai atnaujinti ✅';
      showCustomSnackBar(context, successMessage, true);

      // Uždarome ekraną po sėkmingo atnaujinimo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } catch (e) {
      // Rodo klaidos pranešimą
      String errorMessage = 'Klaida išsaugant duomenis ❌';
      showCustomSnackBar(context, errorMessage, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fiksuoti tarpai
    const double topPadding = 25.0; // Tarpas nuo viršaus
    const double horizontalPadding = 20.0; // Tarpai iš šonų
    const double bottomPadding =
        20.0; // Tarpas nuo apačios (virš BottomNavigation)

    // Gauname ekrano matmenis
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF8093F1),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: topPadding,
            ),
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
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        ElevatedButton(
                          onPressed: _saveUserData, // Paspaudus išsaugoti
                          child: Text('Išsaugoti'),
                        ),
                      ],
                    ),
                    // GestureDetector(
                    //   onTap: _showIconSelectionDialog,
                    //   child: Stack(
                    //     alignment: Alignment.center,
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 60,
                    //         backgroundColor: Color(0xFFD9D9D9),
                    //         child: Icon(
                    //           availableIcons[selectedIconName],
                    //           size: 100,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       Container(
                    //         width: 120,
                    //         height: 120,
                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           color: Colors.black.withOpacity(0.3),
                    //         ),
                    //         child: Center(
                    //           child: Text(
                    //             'Keisti',
                    //             style: TextStyle(color: Colors.white),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: _showIconSelectionDialog,
                      child: Stack(
                        children: [
                          // Centrinė account_circle ikona
                          Stack(
                            alignment:
                                Alignment.center, // Centruoja tekstą ant ikonos
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Color(
                                      0xFFD9D9D9), // Naudojame skaidrų filtrą su blur efektu
                                  BlendMode
                                      .srcIn, // Blend mode, kad būtų matomas tik blur efektas
                                ),
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                      sigmaX: 3.0,
                                      sigmaY: 3.0), // Blur stiprumas
                                  child: Icon(
                                    availableIcons[selectedIconName],
                                    size: 200,
                                    color: Color(0xFFD9D9D9),
                                  ),
                                ),
                              ),
                              const Text(
                                'Keisti profilio\nnuotrauką',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller:
                            _userNameController, // Naudojame kontrollerį
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Vardas',
                        ),
                      ),
                    ),
                    Text(
                      userUsername,
                      style: TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Mano duomenys',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
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
                    SizedBox(
                      height: 15,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       'Versija:',
                    //       style: TextStyle(fontSize: 20),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VersionScreen(username: userUsername)),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: (screenSize.width - 2 * horizontalPadding) *
                                0.8,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.deepPurple.shade700, width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.asset(
                                'assets/images/versijos_keitimas.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // VersionSelection(
                    //   currentVersion: widget.version,
                    //   onVersionChanged: (newVersion) {
                    //     setState(() {
                    //       userVersion = newVersion;
                    //     });
                    //   },
                    // ),
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

  void _showIconSelectionDialog() async {
    String? newIcon = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pasirink profilio ikoną'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: availableIcons.entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, entry.key);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.value, size: 40),
                      //Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (newIcon != null) {
      setState(() {
        selectedIconName = newIcon;
      });
    }
  }
}
