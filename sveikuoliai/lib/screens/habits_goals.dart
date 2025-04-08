import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/screens/goal.dart';
import 'package:sveikuoliai/screens/habit.dart';
import 'package:sveikuoliai/screens/new_goal.dart';
import 'package:sveikuoliai/screens/new_habit.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';

class HabitsGoalsScreen extends StatefulWidget {
  const HabitsGoalsScreen({super.key});

  @override
  _HabitsGoalsScreenState createState() => _HabitsGoalsScreenState();
}

class _HabitsGoalsScreenState extends State<HabitsGoalsScreen> {
  int selectedIndex =
      0; // 0 - Mano įpročiai, 1 - Mano tikslai, 2 - Draugu tikslai
  String userUsername = "";
  final AuthService _authService = AuthService();
  List<HabitInformation> userHabits = [];
  List<GoalInformation> userGoals = [];
  final HabitService _habitService = HabitService();
  final GoalService _goalService = GoalService();

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
      await _fetchUserGoals(userUsername);
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

  Future<void> _fetchUserGoals(String username) async {
    try {
      // Gaukime vartotojo įpročius
      List<GoalInformation> goals = await _goalService.getUserGoals(username);

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userGoals = goals;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant tikslus ❌', false);
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
                                    ? Color(0xFFB388EB)
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
                                    ? Color(0xFF72ddf7)
                                    : Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                                border: selectedIndex == 2
                                    ? Border(
                                        left: BorderSide(
                                          color:
                                              Colors.grey[400] ?? Colors.grey,
                                          width: 2,
                                        ),
                                      )
                                    : null,
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
                    SizedBox(
                        height:
                            10), // Tarpas tarp pirmos eilės ir trečio mygtuko
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = 2;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedIndex == 2
                              ? Color(0xFFbcd979)
                              : Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Mano tikslai su draugais',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedIndex == 2
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    //SizedBox(height: 10),
                    // Turinys pagal pasirinkimą
                    Expanded(
                      child: selectedIndex == 0
                          ? _buildHabits()
                          : selectedIndex == 1
                              ? _buildGoals()
                              : _buildFriendsGoals(), // Nauja funkcija draugų tikslams
                    ),
                  ],
                )),
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
                          child: Icon(Icons.add_circle,
                              size: 80, // Ikonos dydis
                              color: Color(0xFFEEE2FB) // Ikonos spalva
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
        ...userHabits.map((habit) => _habitItem(habit)),
      ],
    );
  }

  Widget _habitItem(HabitInformation habit) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitScreen(habit: habit),
          ),
        );
        ;
      },
      child: Column(
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
                    // Apskritimo ikona fone
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.circle,
                        size: 80, // Ikonos dydis
                        color: Color(0xFFF4EDFC), // Ikonos spalva
                      ),
                    ),

                    // Augalo paveiksliukas ant viršaus
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        PlantImageService.getPlantImage(
                            habit.habitModel.plantId, habit.habitModel.points),
                        width: 80,
                        height: 80,
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
                            color: Color(0xFFD5F8FD), // Ikonos spalva
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
        ...userGoals.map((goal) => _goalItem(goal)),
      ],
    );
  }

  Widget _goalItem(GoalInformation goal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GoalScreen(goal: goal), // Pakeisk į tinkamą puslapį
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Apskritimo ikona fone
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.circle,
                        size: 80, // Ikonos dydis
                        color: Color(0xFFE5FAFE), // Ikonos spalva
                      ),
                    ),

                    // Augalo paveiksliukas ant viršaus
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        PlantImageService.getPlantImage(
                            goal.goalModel.plantId, goal.goalModel.points),
                        width: 80,
                        height: 80,
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
                        goal.goalType.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF72ddf7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.goalType.description,
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

  Widget _buildFriendsGoals() {
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
                          color: Color(0xFFbcd979), // Pasirinkta spalva
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
                            color: Color(0xFFE4F7B4), // Ikonos spalva
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
                            color: Color(0xFFbcd979),
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
        ...userGoals.map((goal) => _friendsGoalItem(goal)),
      ],
    );
  }

  Widget _friendsGoalItem(GoalInformation goal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GoalScreen(goal: goal), // Pakeisk į tinkamą puslapį
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Apskritimo ikona fone
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.circle,
                        size: 80, // Ikonos dydis
                        color: Color(0xFFECFFC5), // Ikonos spalva
                      ),
                    ),

                    // Augalo paveiksliukas ant viršaus
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        PlantImageService.getPlantImage(
                            goal.goalModel.plantId, goal.goalModel.points),
                        width: 80,
                        height: 80,
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
                        goal.goalType.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFbcd979),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.goalType.description,
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
