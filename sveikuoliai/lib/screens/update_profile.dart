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
  String? _nameError; // To store the error message
  bool isDarkMode = false; // Temos būsena

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();

  final List<String> availableIcons = [
    'assets/images/avatarai/1.png',
    'assets/images/avatarai/2.png',
    'assets/images/avatarai/3.png',
    'assets/images/avatarai/4.png',
    'assets/images/avatarai/5.png',
    'assets/images/avatarai/6.png',
    'assets/images/avatarai/7.png',
    'assets/images/avatarai/8.png',
    'assets/images/avatarai/9.png',
    'assets/images/avatarai/10.png',
    'assets/images/avatarai/11.png',
    'assets/images/avatarai/12.png',
    'assets/images/avatarai/13.png',
    'assets/images/avatarai/14.png',
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
        isDarkMode =
            sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
        _userNameController.text = userName;
        _userEmailController.text = userEmail;
      });
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _nameError = _userNameController.text.trim().isEmpty
          ? 'Vardas negali būti tuščias!'
          : null; // Validate and set error
    });

    if (_nameError == null) {
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
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
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
                        ElevatedButton(
                          onPressed: _saveUserData,
                          child: Text(
                            'Išsaugoti',
                          ),
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
                                      ? (isDarkMode
                                          ? Colors.grey[400]!
                                          : const Color(0xFFD9D9D9))
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
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : const Color(0xFFD9D9D9),
                                        )
                                      : Image.asset(
                                          selectedIconName,
                                          width: 190,
                                          height: 190,
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              Text(
                                'Keisti profilio\navatarą',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _userNameController,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Vardas',
                              labelStyle: TextStyle(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _nameError = value.trim().isEmpty
                                    ? 'Vardas negali būti tuščias!'
                                    : null;
                              });
                            },
                          ),
                          if (_nameError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, left: 10.0),
                              child: Text(
                                _nameError!,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.red[300] : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      userUsername,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF8093F1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Mano duomenys',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'El. paštas',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black,
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
                                    VersionScreen(username: userUsername),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: (screenSize.width - 2 * horizontalPadding) *
                                0.8,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.deepPurple.shade500
                                    : Colors.deepPurple.shade700,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black54
                                      : Colors.black26,
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
          title: Text(
            'Pasirink profilio avatarą',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
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
                        color: isDarkMode ? Colors.white : Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
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
