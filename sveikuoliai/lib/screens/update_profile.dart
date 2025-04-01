import 'package:flutter/material.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'dart:ui';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/versionSelection.dart';

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

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();

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

      // Atnaujiname vartotojo duomenis paslaugos pagalba
      await _userService.updateUserData(userUsername, newName, newEmail, newVersion);

      // Atvaizduojame sėkmės pranešimą
      String successMessage = 'Duomenys sėkmingai atnaujinti ✅';
      showCustomSnackBar(context, successMessage, true);

      // Uždarome ekraną po sėkmingo atnaujinimo
      Navigator.pop(context);
    } catch (e) {
      // Rodo klaidos pranešimą
      String errorMessage = 'Klaida išsaugant duomenis ❌';
      showCustomSnackBar(context, errorMessage, false);
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
                      ElevatedButton(
                        onPressed: _saveUserData, // Paspaudus išsaugoti
                        child: Text('Išsaugoti'),
                      ),
                    ],
                  ),
                  Stack(
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
                                  sigmaX: 5.0, sigmaY: 5.0), // Blur stiprumas
                              child: Icon(
                                Icons.account_circle,
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
                  IntrinsicWidth(
                    child: TextField(
                      controller: _userNameController, // Naudojame kontrollerį
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      IntrinsicWidth(
                        child: TextField(
                          controller:
                              _userEmailController, // Naudojame kontrollerį
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFB388EB),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFB388EB),
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'el. paštas',
                          ),
                        ),
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
                        'Versija:',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  VersionSelection(
                    currentVersion: widget.version,
                    onVersionChanged: (newVersion) {
                      setState(() {
                        userVersion = newVersion;
                      });
                    },
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
