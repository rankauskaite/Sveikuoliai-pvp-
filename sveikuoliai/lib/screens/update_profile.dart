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
  final UserService _userService = UserService();
  String userUsername = "";
  String userName = "";
  String userEmail = "";
  String userVersion = "";
  String selectedIconName = 'account_circle'; // Default to account_circle

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();

  final List<String> availableIcons = [
    'assets/images/avatarai/1.png',
    'assets/images/avatarai/2.png',
    'assets/images/avatarai/3.png',
    'assets/images/avatarai/4.png',
    'assets/images/avatarai/5.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      setState(() {
        userUsername = sessionData['username'] ?? "Nežinomas";
        userName = sessionData['name'] ?? "Nežinomas";
        userEmail = sessionData['email'] ?? "Nežinomas";
        userVersion = sessionData['version'] ?? "Nežinomas";
        selectedIconName = sessionData['icon']?.isNotEmpty == true
            ? sessionData['icon']!
            : 'account_circle';

        _userNameController.text = userName;
        _userEmailController.text = userEmail;
      });
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _saveUserData() async {
    try {
      String newName = _userNameController.text;
      String newEmail = _userEmailController.text;
      String newVersion = userVersion;
      String? newIcon =
          selectedIconName == 'account_circle' ? '' : selectedIconName;

      await _userService.updateUserData(
          userUsername, newName, newEmail, newVersion, newIcon);
      _authService.updateUserSession('name', newName);
      _authService.updateUserSession('email', newEmail);
      _authService.updateUserSession('version', newVersion);
      _authService.updateUserSession('icon', newIcon);

      String successMessage = 'Duomenys sėkmingai atnaujinti ✅';
      showCustomSnackBar(context, successMessage, true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } catch (e) {
      String errorMessage = 'Klaida išsaugant duomenis ❌';
      showCustomSnackBar(context, errorMessage, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

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
            SizedBox(height: topPadding),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                          icon: Icon(Icons.arrow_back_ios, size: 30),
                        ),
                        const Expanded(child: SizedBox()),
                        ElevatedButton(
                          onPressed: _saveUserData,
                          child: Text('Išsaugoti'),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showIconSelectionDialog,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  selectedIconName == 'account_circle'
                                      ? Color(0xFFD9D9D9)
                                      : Colors.transparent,
                                  selectedIconName == 'account_circle'
                                      ? BlendMode.srcIn
                                      : BlendMode.srcOver,
                                ),
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                      sigmaX: 3.0, sigmaY: 3.0),
                                  child: selectedIconName == 'account_circle'
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 200,
                                          color: Color(0xFFD9D9D9),
                                        )
                                      : Image.asset(
                                          selectedIconName,
                                          width: 190,
                                          height: 190,
                                          fit: BoxFit.fill,
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
                    const SizedBox(height: 10),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _userNameController,
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
                        Text('Mano duomenys', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('El. paštas', style: TextStyle(fontSize: 12)),
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
                    SizedBox(height: 15),
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
              children: [
                // "None" option (account_circle)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, 'account_circle');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        size: 50,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
                // Avatar images
                ...availableIcons.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, entry);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          entry,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
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
