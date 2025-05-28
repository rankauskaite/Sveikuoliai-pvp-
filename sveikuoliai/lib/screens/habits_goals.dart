import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/friendship_model.dart';
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
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/profile_button.dart';

class HabitsGoalsScreen extends StatefulWidget {
  final int selectedIndex;
  const HabitsGoalsScreen({Key? key, required this.selectedIndex})
      : super(key: key);

  @override
  _HabitsGoalsScreenState createState() => _HabitsGoalsScreenState();
}

class _HabitsGoalsScreenState extends State<HabitsGoalsScreen> {
  late int selectedIndex;
  String userUsername = "";
  String userVersion = "";
  String date = DateTime.now().toIso8601String().split('T').first;
  final AuthService _authService = AuthService();
  List<HabitInformation> userHabits = [];
  List<GoalInformation> userGoals = [];
  List<SharedGoalInformation> userSharedGoals = [];
  List<FriendshipModel> friends = [];
  final SharedGoalService _sharedGoalService = SharedGoalService();
  bool isDarkMode = false; // Temos būsena

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
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
          isDarkMode =
              sessionData['darkMode'] == 'true'; // Gauname darkMode iš sesijos
        },
      );
      await _fetchUserHabits();
      await _fetchUserGoals();
      if (userVersion == 'premium') {
        await _fetchUserSharedGoals(userUsername);
        await _fetchUserFriends(userUsername);
      }
    } catch (e) {
      String message = 'Klaida gaunant duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _fetchUserHabits() async {
    try {
      List<HabitInformation> habits = await _authService.getHabitsFromSession();
      bool updated = false;

      for (var habit in habits) {
        if (habit.habitModel.endDate.isBefore(DateTime.now()) &&
            !habit.habitModel.isCompleted) {
          habit.habitModel.isCompleted = true;
          updated = true;
        }
      }

      if (updated) {
        await _authService.saveHabitsToSession(habits);
      }

      setState(() {
        userHabits = habits;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant įpročius ❌', false);
    }
  }

  Future<void> _fetchUserGoals() async {
    try {
      List<GoalInformation> goals = await _authService.getGoalsFromSession();
      bool updated = false;

      for (var goal in goals) {
        if (goal.goalModel.endDate.isBefore(DateTime.now()) &&
            !goal.goalModel.isCompleted) {
          goal.goalModel.isCompleted = true;
          updated = true;
        }
      }

      if (updated) {
        await _authService.saveGoalsToSession(goals);
      }

      setState(() {
        userGoals = goals;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant tikslus ❌', false);
    }
  }

  Future<void> _fetchUserSharedGoals(String username) async {
    try {
      List<SharedGoalInformation> goals =
          await _authService.getSharedGoalsFromSession();
      bool updated = false;

      for (var goal in goals) {
        if (goal.sharedGoalModel.endDate.isBefore(DateTime.now()) &&
            (!goal.sharedGoalModel.isCompletedUser1 ||
                !goal.sharedGoalModel.isCompletedUser2)) {
          goal.sharedGoalModel.isCompletedUser1 = true;
          goal.sharedGoalModel.isCompletedUser2 = true;
          updated = true;
        }
      }

      if (updated) {
        await _authService.saveSharedGoalsToSession(goals);
      }

      goals.sort((a, b) {
        bool aActive = a.sharedGoalModel.isApproved;
        bool bActive = b.sharedGoalModel.isApproved;
        if (aActive && !bActive) return -1;
        if (!aActive && bActive) return 1;
        return 0;
      });

      setState(() {
        userSharedGoals = goals;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant bendrus tikslus ❌', false);
    }
  }

  Future<void> _fetchUserFriends(String username) async {
    try {
      List<FriendshipModel> friendsList =
          await _authService.getFriendsFromSession();
      List<FriendshipModel> friendsListFiltered = friendsList
          .where((friendship) => friendship.friendship.status == 'accepted')
          .toList();
      setState(() {
        friends = friendsListFiltered;
      });
    } catch (e) {
      String message = 'Klaida gaunant draugų duomenis ❌';
      if (mounted) {
        showCustomSnackBar(context, message, false);
      }
    }
  }

  Future<void> _confirmSharedGoal(SharedGoalInformation goal) async {
    try {
      setState(() {
        goal.sharedGoalModel.isApproved = true;
      });
      await _sharedGoalService.updateSharedGoalEntry(goal.sharedGoalModel);
      setState(() {
        userSharedGoals.removeWhere(
            (f) => f.sharedGoalModel.id == goal.sharedGoalModel.id);
        userSharedGoals.add(goal);
      });
      await _authService.saveSharedGoalsToSession(userSharedGoals);
      showCustomSnackBar(context, "Bendras tikslas patvirtinta ✅", true);
      await _fetchUserSharedGoals(userUsername);
    } catch (e) {
      showCustomSnackBar(
          context, "Nepavyko patvirtinti bendro tikslo ❌", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 25.0;
    const double horizontalPadding = 20.0;
    const double bottomPadding = 20.0;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFF8093F1),
      ),
      body: Column(
        children: [
          SizedBox(height: topPadding),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                      ProfileButton(),
                    ],
                  ),
                  Row(
                    children: [
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
                                  ? (isDarkMode
                                      ? Colors.purple[500]
                                      : Color(0xFFB388EB))
                                  : (isDarkMode
                                      ? Colors.grey[700]
                                      : Color(0xFFD9D9D9)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                              border: selectedIndex == 2
                                  ? Border(
                                      right: BorderSide(
                                        color: isDarkMode
                                            ? Colors.grey[600]!
                                            : (Colors.grey[400] ?? Colors.grey),
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
                                      ? (isDarkMode
                                          ? Colors.white
                                          : Colors.white)
                                      : (isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.black),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                                  ? (isDarkMode
                                      ? Colors.lightBlue[600]
                                      : Color(0xFF72ddf7))
                                  : (isDarkMode
                                      ? Colors.grey[700]
                                      : Color(0xFFD9D9D9)),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              border: selectedIndex == 2
                                  ? Border(
                                      left: BorderSide(
                                        color: isDarkMode
                                            ? Colors.grey[600]!
                                            : (Colors.grey[400] ?? Colors.grey),
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
                                      ? (isDarkMode
                                          ? Colors.white
                                          : Colors.white)
                                      : (isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.black),
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
                    SizedBox(height: 5),
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
                              ? (isDarkMode
                                  ? Colors.lightGreen[600]
                                  : Color(0xFFbcd979))
                              : (isDarkMode
                                  ? Colors.grey[700]
                                  : Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Mano tikslai su draugais',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedIndex == 2
                                  ? (isDarkMode ? Colors.white : Colors.white)
                                  : (isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.black),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 5),
                  Expanded(
                    child: selectedIndex == 0
                        ? _buildHabits()
                        : selectedIndex == 1
                            ? _buildGoals()
                            : _buildFriendsGoals(userUsername),
                  ),
                ],
              ),
            ),
          ),
          const BottomNavigation(),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHabits() {
    final activeHabits =
        userHabits.where((h) => !h.habitModel.isCompleted).toList();
    final completedHabits =
        userHabits.where((h) => h.habitModel.isCompleted).toList();

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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color:
                              userVersion == 'free' && activeHabits.length >= 3
                                  ? (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[600])
                                  : (isDarkMode
                                      ? Colors.purple[700]
                                      : Color(0xFFB388EB)),
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
                                  ? (isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey[300])
                                  : (isDarkMode
                                      ? Colors.purple[200]
                                      : Color(0xFFEEE2FB))),
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
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Nori neribotų įpročių? Užsisakyk Gija PLIUS!',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.black54),
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
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.purple[200]
                                  : const Color(0xFFB388EB),
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
        ...activeHabits.map((habit) => _habitItem(habit)),
        if (completedHabits.isNotEmpty) ...[
          Center(
            child: Text(
              'Baigti įpročiai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.purple : Color(0xFF7E5BB5),
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
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          isDarkMode ? Colors.purple[100] : Color(0xFFF4EDFC),
                      child: Icon(
                        Icons.circle,
                        size: 80,
                        color:
                            isDarkMode ? Colors.purple[100] : Color(0xFFF4EDFC),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        habit.habitModel.isPlantDead
                            ? DeadPlantImageService.getPlantImage(
                                habit.habitModel.plantId,
                                habit.habitModel.points)
                            : PlantImageService.getPlantImage(
                                habit.habitModel.plantId,
                                habit.habitModel.points),
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.habitType.title,
                        style: TextStyle(
                          fontSize: 18,
                          color: habit.habitModel.isCompleted
                              ? (isDarkMode
                                  ? Colors.purple[400]
                                  : Color(0xFF7E5BB5))
                              : (isDarkMode
                                  ? Colors.purple[200]
                                  : Color(0xFFB388EB)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        habit.habitType.description,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color:
                                isDarkMode ? Colors.grey[400] : Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFD9D9D9),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildGoals() {
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color:
                              userVersion == 'free' && activeGoals.length >= 3
                                  ? (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[600])
                                  : (isDarkMode
                                      ? Colors.lightBlue[700]
                                      : Color(0xFF72ddf7)),
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
                          child: Icon(Icons.add_circle,
                              size: 80,
                              color: userVersion == 'free' &&
                                      activeGoals.length >= 3
                                  ? (isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey[300])
                                  : (isDarkMode
                                      ? Colors.lightBlue[200]
                                      : Color(0xFFD5F8FD))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  if (userVersion == 'free' && activeGoals.length >= 3) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasiektas tikslų limitas',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Nori neribotų tikslų? Užsisakyk Gija PLIUS!',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.black54),
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
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightBlue[200]
                                  : const Color(0xFF72ddf7),
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
        ...activeGoals.map((goal) => _goalItem(goal)),
        if (completedGoals.isNotEmpty) ...[
          Center(
            child: Text(
              'Baigti tikslai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode ? Colors.lightBlue.shade600 : Color(0xFF3a8398),
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
            builder: (context) => GoalScreen(goal: goal),
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: isDarkMode
                          ? Colors.lightBlue[100]
                          : Color(0xFFE5FAFE),
                      child: Icon(
                        Icons.circle,
                        size: 80,
                        color: isDarkMode
                            ? Colors.lightBlue[100]
                            : Color(0xFFE5FAFE),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        goal.goalModel.isPlantDead
                            ? DeadPlantImageService.getPlantImage(
                                goal.goalModel.plantId, goal.goalModel.points)
                            : PlantImageService.getPlantImage(
                                goal.goalModel.plantId, goal.goalModel.points),
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalType.title,
                        style: TextStyle(
                          fontSize: 18,
                          color: goal.goalModel.isCompleted
                              ? (isDarkMode
                                  ? Colors.lightBlue[400]
                                  : Color(0xFF3a8398))
                              : (isDarkMode
                                  ? Colors.lightBlue[200]
                                  : Color(0xFF72ddf7)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.goalType.description,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color:
                                isDarkMode ? Colors.grey[400] : Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFD9D9D9),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsGoals(String username) {
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          color: friends.isEmpty
                              ? (isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[600])
                              : (isDarkMode
                                  ? Colors.lightGreen[700]
                                  : Color(0xFFbcd979)),
                          height: 60,
                          width: 60,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: friends.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NewSharedGoalScreen(
                                              username: username,
                                            )),
                                  );
                                },
                          child: Icon(
                            Icons.add_circle,
                            size: 80,
                            color: friends.isEmpty
                                ? (isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.grey[300])
                                : (isDarkMode
                                    ? Colors.lightGreen[200]
                                    : Color(0xFFE4F7B4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  if (friends.isEmpty) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pridėk draugą',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Pridėk draugą, kad galėtum sukurti bendrą tikslą!',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.black54),
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
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightGreen[200]
                                  : const Color(0xFFbcd979),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ],
        ),
        ...activeSharedGoals.map((goal) => _friendsGoalItem(goal)),
        if (mineCompletedSharedGoals.isNotEmpty) ...[
          Center(
            child: Text(
              'Tik mano baigti tikslai su draugais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode ? Colors.lightGreen.shade600 : Color(0xFF6E8F4A),
              ),
            ),
          ),
          const Divider(color: Color(0xFFD9D9D9), thickness: 1),
          ...mineCompletedSharedGoals.map((goal) => _friendsGoalItem(goal)),
        ],
        if (completedSharedGoals.isNotEmpty) ...[
          Center(
            child: Text(
              'Baigti tikslai su draugais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode ? Colors.lightGreen.shade600 : Color(0xFF6E8F4A),
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
    bool isApproved = goal.sharedGoalModel.isApproved;

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
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: isApproved
                          ? (isDarkMode
                              ? Colors.lightGreen[100]
                              : Color(0xFFECFFC5))
                          : (isDarkMode ? Colors.grey[600] : Colors.grey[300]),
                      child: Icon(
                        Icons.circle,
                        size: 80,
                        color: isApproved
                            ? (isDarkMode
                                ? Colors.lightGreen[100]
                                : Color(0xFFECFFC5))
                            : (isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[300]),
                      ),
                    ),
                    if (isApproved)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          goal.sharedGoalModel.isPlantDeadUser1 &&
                                  goal.sharedGoalModel.isPlantDeadUser2
                              ? DeadPlantImageService.getPlantImage(
                                  goal.sharedGoalModel.plantId,
                                  goal.sharedGoalModel.points)
                              : PlantImageService.getPlantImage(
                                  goal.sharedGoalModel.plantId,
                                  goal.sharedGoalModel.points),
                          width: 80,
                          height: 80,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
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
                              ? (isDarkMode
                                  ? Colors.lightGreen[400]
                                  : Color(0xFF6E8F4A))
                              : (isApproved
                                  ? (isDarkMode
                                      ? Colors.lightGreen[200]
                                      : Color(0xFFbcd979))
                                  : (isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.goalType.description,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: isApproved
                              ? (isDarkMode ? Colors.grey[400] : Colors.black54)
                              : (isDarkMode ? Colors.grey[500] : Colors.grey),
                        ),
                      ),
                      if (!isApproved) ...[
                        if (goal.sharedGoalModel.user2Id == userUsername) ...[
                          Row(
                            children: [
                              Transform.translate(
                                offset: Offset(10, 0),
                                child: IconButton(
                                  icon: Icon(Icons.cancel_outlined,
                                      color: isDarkMode
                                          ? Colors.red[300]
                                          : Colors.red.shade300),
                                  onPressed: () {
                                    _showDeclineSharedGoalDialog(goal);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.check_circle,
                                    color: isDarkMode
                                        ? Colors.lightGreen[300]
                                        : Colors.lightGreen.shade400),
                                onPressed: () {
                                  _showConfirmSharedGoalDialog(goal);
                                },
                              ),
                            ],
                          )
                        ] else ...[
                          Text(
                            'Draugas dar nepatvirtino',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.grey[500] : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ]
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFD9D9D9),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  void _showDeclineSharedGoalDialog(SharedGoalInformation goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text.rich(
            TextSpan(
              text: "${goal.goalType.title}\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDarkMode ? Colors.lightGreen[200] : Color(0xFF6E8F4A),
              ),
              children: [
                TextSpan(
                  text: "Bendro tikslo atsisakymas",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          content: Text(
              "Ar tikrai nenorite siekti šio tikslo kartu su draugu @${goal.sharedGoalModel.user1Id}?\nJei atsisakysite tikslas bus panaikintas.",
              style:
                  TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.purple[500]!.withOpacity(0.2)
                        : Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text(
                    "Grįžti",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    await _sharedGoalService
                        .deleteSharedGoalEntry(goal.sharedGoalModel.id);
                    Navigator.of(context).pop();
                    showCustomSnackBar(
                        context, "Bendro tikslo atsisakyta ✅", true);
                    setState(() {
                      FocusScope.of(context).unfocus();
                    });
                    await _fetchUserFriends(userUsername);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.red[500]!.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Text(
                    "Atsisakyti",
                    style: TextStyle(
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showConfirmSharedGoalDialog(SharedGoalInformation goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text.rich(
            TextSpan(
              text: "${goal.goalType.title}\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDarkMode ? Colors.green[200] : Color(0xFF6E8F4A),
              ),
              children: [
                TextSpan(
                  text: "Bendro tikslo patvirtinimas",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          content: Text(
              "Ar norite vykdyti šį tikslą kartu su draugu @${goal.sharedGoalModel.user1Id}?",
              style:
                  TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.purple[500]!.withOpacity(0.2)
                        : Colors.deepPurple.withOpacity(0.2),
                  ),
                  child: Text(
                    "Grįžti",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _confirmSharedGoal(goal);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.green[500]!.withOpacity(0.2)
                        : Color(0xFF6E8F4A).withOpacity(0.2),
                  ),
                  child: Text(
                    "Patvirtinti",
                    style: TextStyle(
                      color: isDarkMode ? Colors.green[300] : Color(0xFF6E8F4A),
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
