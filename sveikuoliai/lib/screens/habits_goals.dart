import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_type_model.dart';
import 'package:sveikuoliai/screens/goal.dart';
import 'package:sveikuoliai/screens/habit.dart';
import 'package:sveikuoliai/screens/new_goal.dart';
import 'package:sveikuoliai/screens/new_habit.dart';
import 'package:sveikuoliai/services/auth_service.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';

class HabitsGoalsScreen extends StatefulWidget {
  const HabitsGoalsScreen({super.key});

  @override
  _HabitsGoalsScreenState createState() => _HabitsGoalsScreenState();
}

class _HabitsGoalsScreenState extends State<HabitsGoalsScreen> {
  int selectedIndex = 0; // 0 - Mano įpročiai, 1 - Mano tikslai
  String userUsername = "";
  final AuthService _authService = AuthService();
  List<HabitInformation> userHabits = [];
  final HabitService _habitService = HabitService();

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
      await _fetchUserHabits(userUsername);
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _fetchUserHabits(String username) async {
    try {
      // Gaukime vartotojo įpročius
      List<HabitInformation> habits =
          await _habitService.getUserHabits(username);

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userHabits = habits;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant įpročius ❌', false);
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
                      ProfileButton(),
                    ],
                  ),
                  Row(
                    children: [
                      // Mano įpročiai
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedIndex == 0
                                  ? Color(0xFFB388EB) // Pažymėta spalva
                                  : Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Mano įpročiai',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedIndex == 0
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Mano tikslai
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 1;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedIndex == 1
                                  ? Color(0xFF72ddf7) // Pažymėta spalva
                                  : Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Mano tikslai',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedIndex == 1
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Rodomas turinys pagal pasirinktą kategoriją
                  Expanded(
                    child: selectedIndex == 0
                        ? _buildHabits() // Rodomi įpročiai
                        : _buildGoals(), // Rodomi tikslai
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

  // Įpročių turinys
  Widget _buildHabits() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ikona / Paveikslėlis kairėje
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Fonas su apvaliais kampais
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(50), // Mažesni apvalūs kampai
                        child: Container(
                          color: Color(0xFFB388EB), // Pasirinkta spalva
                          height: 60, // Fono aukštis
                          width: 60, // Fono plotis
                        ),
                      ),
                      // Mygtukas
                      Material(
                        color: Colors
                            .transparent, // Nustatome, kad mygtuko fonas būtų skaidrus
                        shape: CircleBorder(), // Apvalus mygtukas
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(50), // Apvalūs kampai
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NewHabitScreen()),
                            );
                          }, // Veiksmas paspaudus
                          child: Icon(
                            Icons.add_circle,
                            size: 80, // Ikonos dydis
                            color: Color(0xFFD9D9D9), // Ikonos spalva
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Teksto dalis
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pridėti naują',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFB388EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Linija po Row
            const Divider(
              color: Color(0xFFD9D9D9),
              thickness: 1, // Linijos storis
            ),
          ],
        ),
        ...userHabits.map((habit) => _habitItem(habit)).toList(),
      ],
    );
  }

  // Tikslų turinys
  Widget _buildGoals() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ikona / Paveikslėlis kairėje
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Fonas su apvaliais kampais
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(50), // Mažesni apvalūs kampai
                        child: Container(
                          color: Color(0xFF72ddf7), // Pasirinkta spalva
                          height: 60, // Fono aukštis
                          width: 60, // Fono plotis
                        ),
                      ),
                      // Mygtukas
                      Material(
                        color: Colors
                            .transparent, // Nustatome, kad mygtuko fonas būtų skaidrus
                        shape: CircleBorder(), // Apvalus mygtukas
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(50), // Apvalūs kampai
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NewGoalScreen()),
                            );
                          }, // Veiksmas paspaudus
                          child: Icon(
                            Icons.add_circle,
                            size: 80, // Ikonos dydis
                            color: Color(0xFFD9D9D9), // Ikonos spalva
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Teksto dalis
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pridėti naują',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF72ddf7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Linija po Row
            const Divider(
              color: Color(0xFFD9D9D9),
              thickness: 1, // Linijos storis
            ),
          ],
        ),
        _goalItem("Tikslo pavadinimas"),
        _goalItem("Tikslo pavadinimas"),
        _goalItem("Tikslo pavadinimas"),
        _goalItem("Tikslo pavadinimas"),
      ],
    );
  }

  Widget _habitItem(HabitInformation habit) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitPage(habit: habit), // Perduodame habit
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ikona / Paveikslėlis kairėje
                ClipRRect(
                  borderRadius: BorderRadius.circular(50), // Apvalūs kampai
                  child: Icon(
                    Icons.circle,
                    size: 80,
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(width: 10),
                // Teksto dalis
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.habitType.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFB388EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        habit.habitType.description,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Linija po Row
          const Divider(
            color: Color(0xFFD9D9D9),
            thickness: 1, // Linijos storis
          ),
        ],
      ),
    );
  }

  Widget _goalItem(String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const GoalScreen(), // Pakeisk į tinkamą puslapį
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ikona / Paveikslėlis kairėje
                ClipRRect(
                  borderRadius: BorderRadius.circular(50), // Apvalūs kampai
                  child: Icon(
                    Icons.circle,
                    size: 80,
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(width: 10),
                // Teksto dalis
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF72ddf7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Detalesnė informacija\nKą norėsime parašyti?",
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Linija po Row
          const Divider(
            color: Color(0xFFD9D9D9),
            thickness: 1, // Linijos storis
          ),
        ],
      ),
    );
  }
}
