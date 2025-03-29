import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService =
      UserService(); // Sukuriame UserService instanciją
  String userUsername = "";
  bool notificationsEnabled = true; // Pranešimų būsena
  bool isDarkMode = false; // Temos būsena
  int _selectedDays = 7; // Dabar _selectedDays yra klasės lygyje

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
          userUsername = sessionData['username'] ?? "Nežinomas";
        },
      );
      UserModel? userData = await _userService.getUserEntry(userUsername);
      setState(() {
        notificationsEnabled = userData?.notifications ?? true;
        isDarkMode = userData?.darkMode ?? false;
        _selectedDays = userData?.menstrualLength ?? 7;
      });
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
      // setState(() {
      //   userName = "Klaida gaunant duomenis";
      // });
    }
  }

  // Funkcija, kuri išsaugo nustatytus duomenis duomenų bazėje
// Funkcija, kuri išsaugo tik nustatytus duomenis (pranešimai, tema, mėnesinių trukmė)
  Future<void> _saveSettings() async {
    try {
      bool success = await _userService.updateSettings(
        userUsername, // Vartotojo vardas
        notificationsEnabled, // Pranešimų būsena
        isDarkMode, // Temos būsena
        _selectedDays, // Mėnesinių trukmė
      );

      if (success) {
        String message = 'Nustatymai išsaugoti! 🎉';
        showCustomSnackBar(context, message, success); // Naudokite funkciją
      } else {
        String message = 'Klaida išsaugant nustatymus! ❌';
        showCustomSnackBar(context, message, success); // Naudokite funkciją
      }
    } catch (e) {
      print("Klaida išsaugant nustatymus: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Įvyko klaida!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 320,
              height: 600,
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
                        icon: const Icon(Icons.arrow_back_ios, size: 30),
                      ),
                      const Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          _saveSettings(); // Išsaugo tik nustatytus duomenis
                          Navigator.pop(context);
                        },
                        child: const Text('Išsaugoti'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nustatymai',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Pranešimų nustatymas su keičiamu varpeliu
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        notificationsEnabled = !notificationsEnabled;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          notificationsEnabled
                              ? Icons.notifications_outlined
                              : Icons.notifications_off_outlined,
                          size: 30,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          notificationsEnabled
                              ? 'Pranešimai: gauti'
                              : 'Pranešimai: negauti',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Temos perjungimas su saulute ir menuliu
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          isDarkMode
                              ? Icons.dark_mode
                              : Icons.wb_sunny_outlined,
                          size: 30,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isDarkMode ? 'Tema: tamsi' : 'Tema: šviesi',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pasirinkimas kiek dienų trunka mėnesinės
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 30,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mėnesinių trukmė:',
                        style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(width: 5),
                      // Paspaudus skaičių, rodomas dialogo langas
                      GestureDetector(
                        onTap: () {
                          _showEditDialog(context);
                        },
                        child: Row(
                          children: [
                            Text(
                              _selectedDays.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 30,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Ištrinti paskyrą',
                        style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.delete,
                            color:
                                isDarkMode ? Colors.white : Colors.deepPurple,
                          )),
                    ],
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

  // Dialogo langas su + ir - mygtukais, naudojant atskirą StatefulWidget
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDaysDialog(
          selectedDays: _selectedDays,
          onValueChanged: (newDays) {
            setState(() {
              _selectedDays =
                  newDays; // Atnaujina reikšmę tik pagrindiniame ekrane
            });
          },
        );
      },
    );
  }
}

class EditDaysDialog extends StatefulWidget {
  final int selectedDays;
  final ValueChanged<int> onValueChanged;

  const EditDaysDialog({
    required this.selectedDays,
    required this.onValueChanged,
  });

  @override
  _EditDaysDialogState createState() => _EditDaysDialogState();
}

class _EditDaysDialogState extends State<EditDaysDialog> {
  late int _currentDays;

  @override
  void initState() {
    super.initState();
    _currentDays = widget.selectedDays;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keisti mėnesinių trukmę'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (_currentDays > 0) {
                  _currentDays--;
                }
              });
            },
          ),
          Text(
            _currentDays.toString(),
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                if (_currentDays < 30) {
                  _currentDays++;
                }
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Uždaro dialogą be pakeitimų
          },
          child: const Text('Atšaukti'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              widget.onValueChanged(_currentDays);
            });
            Navigator.pop(context); // Uždaro tik dialogą
          },
          child: const Text('Išsaugoti'),
        ),
      ],
    );
  }
}
