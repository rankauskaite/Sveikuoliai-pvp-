import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/screens/goal.dart';
import 'package:sveikuoliai/screens/habit.dart';
import 'package:sveikuoliai/screens/new_goal.dart';
import 'package:sveikuoliai/screens/new_habit.dart';
import 'package:sveikuoliai/screens/new_shared_goal.dart';
import 'package:sveikuoliai/screens/shared_goal.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
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
  String userVersion = "";
  String date = DateTime.now().toIso8601String().split('T').first;
  final AuthService _authService = AuthService();
  List<HabitInformation> userHabits = [];
  List<GoalInformation> userGoals = [];
  List<SharedGoalInformation> userSharedGoals = [];
  final HabitService _habitService = HabitService();
  final GoalService _goalService = GoalService();
  final SharedGoalService _sharedGoalService = SharedGoalService();

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
          userVersion = sessionData['version'] ?? "Nežinoma";
          date = sessionData['date'] ??
              DateTime.now().toIso8601String().split('T').first;
        },
      );
      await _fetchUserHabits(userUsername);
      await _fetchUserGoals(userUsername);
      if (userVersion == 'premium') {
        await _fetchUserSharedGoals(userUsername);
      }
      setState(() {
        _authService.updateUserSession(
            "date", DateTime.now().toIso8601String().split('T').first);
        date = DateTime.now().toIso8601String().split('T').first;
      });
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

      if (date != DateTime.now().toIso8601String().split('T').first) {
        for (var habit in habits) {
          if (habit.habitModel.endDate.isBefore(DateTime.now())) {
            habit.habitModel.isCompleted = true;
            await _habitService.updateHabitEntry(habit.habitModel);
          }
        }
      }

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

      if (date != DateTime.now().toIso8601String().split('T').first) {
        for (var goal in goals) {
          if (goal.goalModel.endDate.isBefore(DateTime.now())) {
            goal.goalModel.isCompleted = true;
            await _goalService.updateGoalEntry(goal.goalModel);
          }
        }
      }

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userGoals = goals;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant tikslus ❌', false);
    }
  }

  Future<void> _fetchUserSharedGoals(String username) async {
    try {
      // Gaukime vartotojo įpročius
      List<SharedGoalInformation> goals =
          await _sharedGoalService.getSharedUserGoals(username);

      if (date != DateTime.now().toIso8601String().split('T').first) {
        for (var goal in goals) {
          if (goal.sharedGoalModel.endDate.isBefore(DateTime.now())) {
            goal.sharedGoalModel.isCompletedUser1 = true;
            goal.sharedGoalModel.isCompletedUser2 = true;
            await _sharedGoalService
                .updateSharedGoalEntry(goal.sharedGoalModel);
          }
        }
      }

      // Atnaujiname būsena su naujais duomenimis
      setState(() {
        userSharedGoals = goals;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant draugų tikslus ❌', false);
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
                                border: selectedIndex == 2
                                    ? Border(
                                        right: BorderSide(
                                          color:
                                              Colors.grey[400] ?? Colors.grey,
                                          width: 1,
                                        ),
                                      )
                                    : null,
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
                                          width: 1,
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
                    if (userVersion == 'premium') ...[
                      SizedBox(
                          height:
                              5), // Tarpas tarp pirmos eilės ir trečio mygtuko
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
                    ],
                    SizedBox(height: 5),
                    // Turinys pagal pasirinkimą
                    Expanded(
                      child: selectedIndex == 0
                          ? _buildHabits()
                          : selectedIndex == 1
                              ? _buildGoals()
                              : _buildFriendsGoals(
                                  userUsername), // Nauja funkcija draugų tikslams
                    ),
                  ],
                )),
            const BottomNavigation(), // Įterpiama navigacija
          ],
        ),
      ),
    );
  }

  Widget _buildHabits() {
    // Atskiriame įpročius
    final activeHabits =
        userHabits.where((h) => !h.habitModel.isCompleted).toList();
    final completedHabits =
        userHabits.where((h) => h.habitModel.isCompleted).toList();

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Viršutinė dalis su mygtuku
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color:
                              userVersion == 'free' && activeHabits.length >= 3
                                  ? Colors.grey[600]
                                  : Color(0xFFB388EB),
                          height: 60,
                          width: 60,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap:
                              userVersion == 'free' && activeHabits.length >= 3
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NewHabitScreen(),
                                        ),
                                      );
                                    },
                          child: Icon(Icons.add_circle,
                              size: 80,
                              color: userVersion == 'free' &&
                                      activeHabits.length >= 3
                                  ? Colors.grey[300]
                                  : Color(0xFFEEE2FB)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  if (userVersion == 'free' && activeHabits.length >= 3) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasiektas įpročių limitas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Nori neribotų įpročių? Užsisakyk Gija PREMIUM!',
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
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
                  ]
                ],
              ),
            ),
            const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ],
        ),

        // Aktyvūs įpročiai
        ...activeHabits.map((habit) => _habitItem(habit)),

        // Jeigu yra bent vienas užbaigtas įprotis, rodom sekciją
        if (completedHabits.isNotEmpty) ...[
          const Center(
            child: Text(
              'Baigti įpročiai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7E5BB5), // A slightly darker shade
              ),
            ),
          ),
          const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ...completedHabits.map((habit) => _habitItem(habit)),
        ],
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
                        style: TextStyle(
                          fontSize: 18,
                          color: habit.habitModel.isCompleted
                              ? Color(0xFF7E5BB5)
                              : Color(0xFFB388EB),
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
    // Atskiriame įpročius
    final activeGoals =
        userGoals.where((g) => !g.goalModel.isCompleted).toList();
    final completedGoals =
        userGoals.where((g) => g.goalModel.isCompleted).toList();

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
                          color:
                              userVersion == 'free' && activeGoals.length >= 3
                                  ? Colors.grey[600]
                                  : Color(0xFF72ddf7), // Pasirinkta spalva
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
                          onTap:
                              userVersion == 'free' && activeGoals.length >= 3
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NewGoalScreen(),
                                        ),
                                      );
                                    },
                          child: Icon(
                            Icons.add_circle,
                            size: 80,
                            color:
                                userVersion == 'free' && activeGoals.length >= 3
                                    ? Colors.grey[300]
                                    : Color(0xFFD5F8FD), // Ikonos spalva
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Teksto dalis
                  if (userVersion == 'free' && activeGoals.length >= 3) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasiektas tikslų limitas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Nori neribotų tikslų? Užsisakyk Gija PREMIUM!',
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
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
                  ]
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
        ...activeGoals.map((goal) => _goalItem(goal)),

        // Jeigu yra bent vienas užbaigtas įprotis, rodom sekciją
        if (completedGoals.isNotEmpty) ...[
          const Center(
            child: Text(
              'Baigti tikslai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3a8398), // A slightly darker shade
              ),
            ),
          ),
          const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ...completedGoals.map((goal) => _goalItem(goal)),
        ],
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
                        style: TextStyle(
                          fontSize: 18,
                          color: goal.goalModel.isCompleted
                              ? Color(0xFF3a8398)
                              : Color(0xFF72ddf7),
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

  Widget _buildFriendsGoals(String username) {
    // Atskiriame įpročius
    final activeSharedGoals = userSharedGoals
        .where((g) =>
            !g.sharedGoalModel.isCompletedUser1 &&
            !g.sharedGoalModel.isCompletedUser2)
        .toList();
    final mineCompletedSharedGoals = userSharedGoals
        .where((g) =>
            (username == g.sharedGoalModel.user1Id
                ? g.sharedGoalModel.isCompletedUser1
                : g.sharedGoalModel.isCompletedUser2) &&
            (username == g.sharedGoalModel.user1Id
                ? !g.sharedGoalModel.isCompletedUser2
                : !g.sharedGoalModel.isCompletedUser1))
        .toList();
    final completedSharedGoals = userSharedGoals
        .where((g) =>
            g.sharedGoalModel.isCompletedUser1 &&
            g.sharedGoalModel.isCompletedUser2)
        .toList();

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
                                  builder: (context) => NewSharedGoalScreen(
                                        username: username,
                                      )),
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
        ...activeSharedGoals.map((goal) => _friendsGoalItem(goal)),

        // Jeigu yra bent vienas užbaigtas įprotis, rodom sekciją
        if (mineCompletedSharedGoals.isNotEmpty) ...[
          const Center(
            child: Text(
              'Tik mano baigti tikslai su draugais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E8F4A), // A slightly darker shade
              ),
            ),
          ),
          const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ...mineCompletedSharedGoals.map((goal) => _friendsGoalItem(goal)),
        ],

        // Jeigu yra bent vienas užbaigtas įprotis, rodom sekciją
        if (completedSharedGoals.isNotEmpty) ...[
          const Center(
            child: Text(
              'Baigti tikslai su draugais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E8F4A), // A slightly darker shade
              ),
            ),
          ),
          const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ...completedSharedGoals.map((goal) => _friendsGoalItem(goal)),
        ],
      ],
    );
  }

  Widget _friendsGoalItem(SharedGoalInformation goal) {
    bool isApproved = goal.sharedGoalModel.isApproved; // Tavo tikrinama reikšmė

    return GestureDetector(
      onTap: isApproved
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SharedGoalScreen(goal: goal),
                ),
              );
            }
          : null, // Jeigu isApproved false, negalima spustelėti
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
                        color: isApproved
                            ? Color(0xFFECFFC5) // Jei patvirtinta, spalva kita
                            : Colors
                                .grey[300], // Jei nepatvirtinta, pilka spalva
                      ),
                    ),
                    // Augalo paveiksliukas ant viršaus
                    if (isApproved)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          PlantImageService.getPlantImage(
                              goal.sharedGoalModel.plantId,
                              goal.sharedGoalModel.points),
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
                        style: TextStyle(
                          fontSize: 18,
                          color: goal.sharedGoalModel.isCompletedUser1 ||
                                  goal.sharedGoalModel.isCompletedUser2
                              ? Color(0xFF6E8F4A)
                              : isApproved
                                  ? Color(
                                      0xFFbcd979) // Jei patvirtinta, spalva kita
                                  : Colors
                                      .grey, // Jei nepatvirtinta, pilka spalva
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.goalType.description,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: isApproved
                              ? Colors.black54
                              : Colors.grey, // Jei nepatvirtinta, pilka spalva
                        ),
                      ),
                      if (!isApproved)
                        Text(
                          'Draugas dar nepatvirtino',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
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
