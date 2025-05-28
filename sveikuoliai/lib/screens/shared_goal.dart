import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_dialogs.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/goal_progress_graph.dart';
import 'package:sveikuoliai/widgets/goal_task_card.dart';
import 'package:sveikuoliai/widgets/progress_indicator.dart';
import 'package:sveikuoliai/widgets/shared_goal_progress_graph.dart';

class SharedGoalScreen extends StatefulWidget {
  final SharedGoalInformation goal;
  const SharedGoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  _SharedGoalPageState createState() => _SharedGoalPageState();
}

class _SharedGoalPageState extends State<SharedGoalScreen> {
  PlantModel plant = PlantModel(
    id: '',
    name: '',
    points: 0,
    photoUrl: '',
    duration: 0,
  );
  final GoalTaskService _goalTaskService = GoalTaskService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  List<GoalTask> goalTasksMine = [];
  List<GoalTask> goalTasksFriend = [];
  int _currentPage = 0;
  PageController _pageController = PageController();
  int lengthMine = 0;
  int doneLengthMine = 0;
  int lengthFriend = 0;
  int doneLengthFriend = 0;
  String friendUsername = '';
  String friendName = '';
  String username = '';
  bool isDarkMode = false; // Temos būsena
  bool isPlantDeadMine = false;
  bool isPlantDeadFriend = false;
  late DateTime lastDoneDate;
  late DateTime lastDoneDateFriend;

  @override
  void initState() {
    super.initState();
    lastDoneDate = widget.goal.sharedGoalModel.startDate;
    lastDoneDateFriend = widget.goal.sharedGoalModel.startDate;
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchSessionUser();
    await _fetchPlantData();
    await _fetchGoalTask();
  }

  Future<void> _fetchSessionUser() async {
    if (username.isEmpty) {
      try {
        Map<String, String?> sessionData = await _authService.getSessionUser();
        String userId =
            widget.goal.sharedGoalModel.user1Id == sessionData['username']
                ? widget.goal.sharedGoalModel.user2Id
                : widget.goal.sharedGoalModel.user1Id;
        bool isDead =
            widget.goal.sharedGoalModel.user1Id == sessionData['username']
                ? widget.goal.sharedGoalModel.isPlantDeadUser1
                : widget.goal.sharedGoalModel.isPlantDeadUser2;
        bool isDeadFriend = widget.goal.sharedGoalModel.user1Id == userId
            ? widget.goal.sharedGoalModel.isPlantDeadUser2
            : widget.goal.sharedGoalModel.isPlantDeadUser1;
        UserModel? name = await _userService.getUserEntry(userId);
        setState(() {
          username = sessionData['username'] ?? "Nežinomas";
          friendUsername = userId;
          friendName = name?.name ?? "Nežinomas";
          isPlantDeadMine = isDead;
          isPlantDeadFriend = isDeadFriend;
          isDarkMode = sessionData['darkMode'] == 'true'; // Gauname darkMode
        });
      } catch (e) {
        setState(() {
          username = "Klaida gaunant duomenis";
        });
      }
    }
  }

  Future<void> _fetchPlantData() async {
    try {
      List<PlantModel> plants = await _authService.getPlantsFromSession();
      PlantModel? fetchedPlant = plants.firstWhere(
        (p) => p.id == widget.goal.sharedGoalModel.plantId,
      );
      setState(() {
        plant = fetchedPlant;
      });
    } catch (e) {
      String message = 'Klaida gaunant augalo duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _fetchGoalTask() async {
    try {
      List<GoalTask> tasksMine = await _goalTaskService.getGoalTasksForUser(
          widget.goal.sharedGoalModel.id, username);
      List<GoalTask> tasksFriend = await _goalTaskService.getGoalTasksForUser(
          widget.goal.sharedGoalModel.id, friendUsername);

      tasksMine.sort((a, b) => a.id.compareTo(b.id));
      tasksFriend.sort((a, b) => a.id.compareTo(b.id));

      setState(() {
        goalTasksMine = tasksMine;
        goalTasksFriend = tasksFriend;
        lengthMine = tasksMine.length;
        lengthFriend = tasksFriend.length;
        doneLengthMine = tasksMine.where((task) => task.isCompleted).length;
        doneLengthFriend = tasksFriend.where((task) => task.isCompleted).length;

        final completedTasks =
            tasksMine.where((task) => task.isCompleted).toList();
        if (completedTasks.isNotEmpty) {
          lastDoneDate = completedTasks
              .map((task) => task.date)
              .reduce((a, b) => a.isAfter(b) ? a : b);
        }

        final completedTasksFriend =
            tasksFriend.where((task) => task.isCompleted).toList();
        if (completedTasksFriend.isNotEmpty) {
          lastDoneDateFriend = completedTasksFriend
              .map((task) => task.date)
              .reduce((a, b) => a.isAfter(b) ? a : b);
        }
      });

      bool isDead = isPlantDead(lastDoneDate, true);
      setState(() {
        widget.goal.sharedGoalModel.isPlantDeadUser1 = isDead;
        isPlantDeadMine = isDead;
      });
      await _sharedGoalService
          .updateSharedGoalEntry(widget.goal.sharedGoalModel);
      // Atnaujiname sesiją su naujausiais duomenimis
      List<SharedGoalInformation> goals =
          await _authService.getSharedGoalsFromSession();
      int goalIndex = goals.indexWhere(
          (g) => g.sharedGoalModel.id == widget.goal.sharedGoalModel.id);
      if (goalIndex != -1) {
        goals[goalIndex] = widget.goal; // Atnaujiname esamą tikslą
      } else {
        goals.add(widget.goal); // Jei tikslo dar nėra, pridedame
      }
      await _authService.saveSharedGoalsToSession(goals);
      bool isDeadFriend = isPlantDead(lastDoneDateFriend, false);
      setState(() {
        widget.goal.sharedGoalModel.isPlantDeadUser2 = isDeadFriend;
        isPlantDeadFriend = isDeadFriend;
      });
      await _sharedGoalService
          .updateSharedGoalEntry(widget.goal.sharedGoalModel);
      if (goalIndex != -1) {
        goals[goalIndex] = widget.goal; // Atnaujiname esamą tikslą
      } else {
        goals.add(widget.goal); // Jei tikslo dar nėra, pridedame
      }
      await _authService.saveSharedGoalsToSession(goals);
    } catch (e) {
      showCustomSnackBar(
          context, 'Klaida kraunant draugų tikslo užduotis ❌', false);
    }
  }

  Future<void> _saveGoalStates() async {
    try {
      for (var task in goalTasksMine) {
        await _goalTaskService.updateGoalTaskState(
          task.id,
          task.isCompleted,
          task.points,
        );
      }
      await _sharedGoalService.updateGoalPoints(
          widget.goal.sharedGoalModel.id, _userPoints(goalTasksMine));

      setState(() {
        widget.goal.sharedGoalModel.points = _allPoints();
      });

      final allCompleted = goalTasksMine.every((task) => task.isCompleted);
      if (allCompleted) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              title: Text(
                "Sveikiname! 🎉",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Text(
                "Įvykdėte visas užduotis. Ką norėtumėte daryti toliau?",
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    username == widget.goal.sharedGoalModel.user1Id
                        ? widget.goal.sharedGoalModel.isCompletedUser1 = true
                        : widget.goal.sharedGoalModel.isCompletedUser2 = true;
                    _sharedGoalService
                        .updateSharedGoalEntry(widget.goal.sharedGoalModel);
                    setState(() {
                      username == widget.goal.sharedGoalModel.user1Id
                          ? widget.goal.sharedGoalModel.isCompletedUser1 = true
                          : widget.goal.sharedGoalModel.isCompletedUser2 = true;
                    });
                    showCustomSnackBar(
                        context, "Tikslas sėkmingai užbaigtas ✅", true);
                  },
                  child: Text(
                    "Užbaigti tikslą",
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.lightGreen[300]
                          : Colors.lightGreen,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    CustomDialogs.showNewFirstTaskDialog(
                      context: context,
                      type: 1,
                      onSave: (newTask) => _createTask(newTask),
                      goal: widget.goal,
                      accentColor: isDarkMode
                          ? Colors.lightGreen[300]!
                          : Colors.lightGreen[400]!,
                    );
                  },
                  child: Text(
                    "Pridėti užduotį",
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.lightGreen[300]
                          : Colors.lightGreen,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          showCustomSnackBar(
              context, "Tikslo būsena sėkmingai išsaugota ✅", true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SharedGoalScreen(
                goal: widget.goal,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Klaida išsaugant tikslo būseną ❌", false);
      }
    }
  }

  bool isPlantDead(DateTime date, bool isMine) {
    DateTime today = DateTime.now();
    DateTime twoDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 2));
    DateTime threeDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 3));
    DateTime weekAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 7));
    if (widget.goal.sharedGoalModel.plantId == "dobiliukas" &&
        date.isBefore(twoDaysAgo)) {
      if (isMine) {
        showCustomPlantSnackBar(
          context,
          "${getPlantName(widget.goal.sharedGoalModel.plantId)} bent 2 dienas 🥺",
        );
      }
      return true;
    } else if (widget.goal.sharedGoalModel.plantId == "ramuneles" ||
        widget.goal.sharedGoalModel.plantId == "zibuokle" ||
        widget.goal.sharedGoalModel.plantId == "saulegraza") {
      if (date.isBefore(threeDaysAgo)) {
        if (isMine) {
          showCustomPlantSnackBar(
            context,
            "${getPlantName(widget.goal.sharedGoalModel.plantId)} bent 3 dienas 🥺",
          );
        }
        return true;
      }
    } else if (widget.goal.sharedGoalModel.plantId == "orchideja" ||
        widget.goal.sharedGoalModel.plantId == "gervuoge" ||
        widget.goal.sharedGoalModel.plantId == "vysnia") {
      if (date.isBefore(weekAgo)) {
        if (isMine) {
          showCustomPlantSnackBar(
            context,
            "${getPlantName(widget.goal.sharedGoalModel.plantId)} bent savaitę 🥺",
          );
        }
        return true;
      }
    }
    return false;
  }

  void showCustomPlantSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      backgroundColor: Colors.lightGreen.shade400.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0), // Viršutinis kairysis kampas
          topRight: Radius.circular(16.0), // Viršutinis dešinysis kampas
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String getPlantName(String plantId) {
    switch (plantId) {
      case 'dobiliukas':
        return 'Dobiliukas nuvyto, nes nebuvo laistomas';
      case 'ramuneles':
        return 'Ramunėlės nuvyto, nes nebuvo laistomos';
      case 'zibuokle':
        return 'Žibuoklė nuvyto, nes nebuvo laistoma';
      case 'saulegraza':
        return 'Saulėgrąža nuvyto, nes nebuvo laistoma';
      case 'orchideja':
        return 'Orchidėja nuvyto, nes nebuvo laistoma';
      case 'gervuoge':
        return 'Gervuogė nuvyto, nes nebuvo laistoma';
      case 'vysnia':
        return 'Vyšnia nuvyto, nes nebuvo laistoma';
      default:
        return '';
    }
  }

  int _allPoints() {
    int sum = 0;
    for (var task in goalTasksMine) {
      sum += task.points;
    }
    for (var task in goalTasksFriend) {
      sum += task.points;
    }
    return (sum / 2).toInt();
  }

  int _userPoints(List<GoalTask> goalTasks) {
    int sum = 0;
    for (var task in goalTasks) {
      sum += task.points;
    }
    return sum;
  }

  double _calculateProgress(List<GoalTask> goalTasks, int flag) {
    if (widget.goal.sharedGoalModel.endPoints == 0) return 0.0;
    return flag == 0
        ? _userPoints(goalTasks) / widget.goal.sharedGoalModel.endPoints
        : _allPoints() / widget.goal.sharedGoalModel.endPoints;
  }

  int _calculatePoints(bool isCompleted, List<GoalTask> goalTasks) {
    if (isCompleted) {
      return (widget.goal.sharedGoalModel.endPoints / goalTasks.length).toInt();
    } else {
      return 0;
    }
  }

  Future<void> _recalculateGoalTaskPoints() async {
    try {
      List<GoalTask> updatedTasks = await _goalTaskService.getGoalTasksForUser(
          widget.goal.sharedGoalModel.id, username);

      for (var task in updatedTasks) {
        int points = _calculatePoints(task.isCompleted, updatedTasks);
        await _goalTaskService.updateGoalTaskState(
          task.id,
          task.isCompleted,
          points,
        );
      }
      updatedTasks = await _goalTaskService.getGoalTasksForUser(
          widget.goal.sharedGoalModel.id, username);

      setState(() {
        goalTasksMine = updatedTasks;
        lengthMine = updatedTasks.length;
        doneLengthMine = updatedTasks.where((task) => task.isCompleted).length;
      });

      int totalPoints = _allPoints();
      print("Total points: $totalPoints");

      await _sharedGoalService.updateGoalPoints(
          widget.goal.sharedGoalModel.id, totalPoints);

      setState(() {
        widget.goal.sharedGoalModel.points = totalPoints;
      });
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Klaida perskaičiuojant taškus ❌", false);
      }
    }
  }

  Future<void> _createTask(GoalTask task) async {
    try {
      await _goalTaskService.createGoalTaskEntry(task);
      await _recalculateGoalTaskPoints();
      showCustomSnackBar(
          context, "Draugų tikslo užduotis sėkmingai pridėta ✅", true);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SharedGoalScreen(
                  goal: widget.goal,
                )),
      );
    } catch (e) {
      showCustomSnackBar(
          context, "Klaida pridedant draugų tikslo užduotį ❌", false);
    }
  }

  Future<void> _deleteGoal() async {
    try {
      final goalService = SharedGoalService();
      await goalService.deleteSharedGoalEntry(widget.goal.sharedGoalModel.id);
      await _authService.removeSharedGoalFromSession(widget.goal);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 2)),
      );
      showCustomSnackBar(context, "Draugų tikslas sėkmingai ištrintas ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant draugų tikslą ❌", false);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final taskService = GoalTaskService();
      await taskService.deleteGoalTaskEntry(taskId);
      await _recalculateGoalTaskPoints();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SharedGoalScreen(
                  goal: widget.goal,
                )),
      );
      showCustomSnackBar(context, "Tikslo užduotis sėkmingai ištrinta ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant tikslo užduotį ❌", false);
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
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: topPadding),
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.white,
                    width: 20,
                  ),
                ),
                child: SingleChildScrollView(
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
                                        HabitsGoalsScreen(selectedIndex: 2)),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          if (widget.goal.goalType.type == 'custom' &&
                              !widget.goal.sharedGoalModel.isCompletedUser1 &&
                              !widget.goal.sharedGoalModel.isCompletedUser2)
                            IconButton(
                              onPressed: () {
                                CustomDialogs.showEditDialog(
                                  context: context,
                                  entityType: EntityType.sharedGoal,
                                  entity: widget.goal,
                                  accentColor: isDarkMode
                                      ? Colors.lightGreen[300]!
                                      : Colors.lightGreen[400]!,
                                  onSave: () {},
                                );
                              },
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 30,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black,
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              CustomDialogs.showDeleteDialog(
                                context: context,
                                entityType: EntityType.sharedGoal,
                                entity: widget.goal,
                                accentColor: isDarkMode
                                    ? Colors.lightGreen[300]!
                                    : Colors.lightGreen,
                                onDelete: () {
                                  _deleteGoal();
                                },
                              );
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
                              color: isDarkMode ? Colors.white70 : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.goal.goalType.title,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.lightGreen[300]
                              : Color(0xFFbcd979),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      _buildBanner(),
                      const SizedBox(height: 20),
                      Text(
                        'Apie tikslą',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.lightGreen[300]
                              : Color(0xFFbcd979),
                        ),
                      ),
                      Text(
                        widget.goal.goalType.description,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Trukmė: ',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white70 : Colors.black,
                            ),
                          ),
                          Text(
                            widget.goal.sharedGoalModel.endPoints == 7
                                ? "1 savaitė"
                                : widget.goal.sharedGoalModel.endPoints == 14
                                    ? "2 savaitės"
                                    : widget.goal.sharedGoalModel.endPoints ==
                                            30
                                        ? "1 mėnuo"
                                        : widget.goal.sharedGoalModel
                                                    .endPoints ==
                                                45
                                            ? "1,5 mėnesio"
                                            : widget.goal.sharedGoalModel
                                                        .endPoints ==
                                                    60
                                                ? "2 mėnesiai"
                                                : widget.goal.sharedGoalModel
                                                            .endPoints ==
                                                        90
                                                    ? "3 mėnesiai"
                                                    : "6 mėnesiai",
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightGreen[300]
                                  : Color(0xFFbcd979),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Pradžios data: ',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white70 : Colors.black,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy MMMM d', 'lt')
                                .format(widget.goal.sharedGoalModel.startDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightGreen[300]
                                  : Color(0xFFbcd979),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Pabaigos data: ',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white70 : Colors.black,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy MMMM d', 'lt')
                                .format(widget.goal.sharedGoalModel.endDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightGreen[300]
                                  : Color(0xFFbcd979),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Augaliukas: ',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white70 : Colors.black,
                            ),
                          ),
                          Text(
                            plant.name,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightGreen[300]
                                  : Color(0xFFbcd979),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (_currentPage != 2) ...[
                        Text(
                          'Užduotys',
                          style: TextStyle(
                            fontSize: 25,
                            color: isDarkMode
                                ? Colors.lightGreen[300]
                                : Color(0xFFbcd979),
                          ),
                        ),
                      ],
                      if (_currentPage == 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (goalTasksMine.isEmpty)
                              Center(
                                child: Text(
                                  'Jūs dar neturite užduočių šiam tikslui.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ...goalTasksMine
                                .where((task) => !task.isCompleted)
                                .map(
                                  (task) => GoalTaskCard(
                                    task: task,
                                    type: 1,
                                    length: lengthMine,
                                    isDoneGoal: username ==
                                            widget.goal.sharedGoalModel.user1Id
                                        ? widget.goal.sharedGoalModel
                                            .isCompletedUser1
                                        : widget.goal.sharedGoalModel
                                            .isCompletedUser2,
                                    isMyTask: true,
                                    doneLength: doneLengthMine,
                                    calculatePoints: (isCompleted) =>
                                        _calculatePoints(
                                            isCompleted, goalTasksMine),
                                    onDelete: _deleteTask,
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                            ...goalTasksMine
                                .where((task) => task.isCompleted)
                                .map(
                                  (task) => GoalTaskCard(
                                    task: task,
                                    type: 1,
                                    isMyTask: true,
                                    isDoneGoal: username ==
                                            widget.goal.sharedGoalModel.user1Id
                                        ? widget.goal.sharedGoalModel
                                            .isCompletedUser1
                                        : widget.goal.sharedGoalModel
                                            .isCompletedUser2,
                                    length: lengthMine,
                                    doneLength: doneLengthMine,
                                    calculatePoints: (isCompleted) =>
                                        _calculatePoints(
                                            isCompleted, goalTasksMine),
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                          ],
                        )
                      else if (_currentPage == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (goalTasksFriend.isEmpty)
                              Center(
                                child: Text(
                                  '$friendName dar neturi užduočių šiam tikslui.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ...goalTasksFriend
                                .where((task) => !task.isCompleted)
                                .map(
                                  (task) => GoalTaskCard(
                                    task: task,
                                    type: 1,
                                    isMyTask: false,
                                    isDoneGoal: username ==
                                            widget.goal.sharedGoalModel.user1Id
                                        ? widget.goal.sharedGoalModel
                                            .isCompletedUser2
                                        : widget.goal.sharedGoalModel
                                            .isCompletedUser1,
                                    length: lengthFriend,
                                    doneLength: doneLengthFriend,
                                    calculatePoints: (isCompleted) =>
                                        _calculatePoints(
                                            isCompleted, goalTasksFriend),
                                    onDelete: null,
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                            ...goalTasksFriend
                                .where((task) => task.isCompleted)
                                .map(
                                  (task) => GoalTaskCard(
                                    task: task,
                                    isMyTask: false,
                                    type: 1,
                                    isDoneGoal: username ==
                                            widget.goal.sharedGoalModel.user1Id
                                        ? widget.goal.sharedGoalModel
                                            .isCompletedUser2
                                        : widget.goal.sharedGoalModel
                                            .isCompletedUser1,
                                    length: lengthFriend,
                                    doneLength: doneLengthFriend,
                                    calculatePoints: (isCompleted) =>
                                        _calculatePoints(
                                            isCompleted, goalTasksFriend),
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      if (_currentPage == 2 &&
                          widget.goal.sharedGoalModel.isCompletedUser1 &&
                          widget.goal.sharedGoalModel.isCompletedUser2) ...[
                        Text(
                          'Įvykdėte bendrą tikslą!',
                          style: TextStyle(
                            fontSize: 25,
                            color: isDarkMode
                                ? Colors.lightGreen[300]
                                : Colors.lightGreen,
                          ),
                        ),
                      ],
                      if (_currentPage == 0) ...[
                        if (username == widget.goal.sharedGoalModel.user1Id
                            ? !widget.goal.sharedGoalModel.isCompletedUser1
                            : !widget
                                .goal.sharedGoalModel.isCompletedUser2) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (goalTasksMine.isNotEmpty)
                                ElevatedButton(
                                  onPressed: () async {
                                    await _saveGoalStates();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        return isDarkMode
                                            ? Colors.grey[800]!
                                            : const Color(0xFFECFFC5);
                                      },
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.lightGreen,
                                    ),
                                  ),
                                  child: Text(
                                    'Išsaugoti',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.lightGreen,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: (widget.goal.sharedGoalModel.user1Id ==
                                    username)
                                ? widget.goal.sharedGoalModel.isCompletedUser1
                                    ? null
                                    : () {
                                        CustomDialogs.showNewTaskDialog(
                                          context: context,
                                          goal: widget.goal,
                                          accentColor: isDarkMode
                                              ? Colors.lightGreen[300]!
                                              : Colors.lightGreen[400]!,
                                          onSave: (GoalTask task) {
                                            _createTask(task);
                                          },
                                        );
                                      }
                                : widget.goal.sharedGoalModel.isCompletedUser2
                                    ? null
                                    : () {
                                        CustomDialogs.showNewTaskDialog(
                                          context: context,
                                          goal: widget.goal,
                                          accentColor: isDarkMode
                                              ? Colors.lightGreen[300]!
                                              : Colors.lightGreen[400]!,
                                          onSave: (GoalTask task) {
                                            _createTask(task);
                                          },
                                        );
                                      },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: isDarkMode
                                  ? (widget.goal.sharedGoalModel.user1Id ==
                                          username
                                      ? (widget.goal.sharedGoalModel
                                              .isCompletedUser1
                                          ? Colors.grey[700]
                                          : Colors.white)
                                      : (widget.goal.sharedGoalModel
                                              .isCompletedUser2
                                          ? Colors.grey[700]
                                          : Colors.white))
                                  : const Color(0xFFE4F7B4),
                              foregroundColor:
                                  isDarkMode ? Colors.black : Colors.lightGreen,
                            ),
                            child: Text(
                              widget.goal.sharedGoalModel.user1Id == username
                                  ? (!widget
                                          .goal.sharedGoalModel.isCompletedUser1
                                      ? 'Pridėti užduotį'
                                      : 'Tikslas įvykdytas')
                                  : (!widget
                                          .goal.sharedGoalModel.isCompletedUser2
                                      ? 'Pridėti užduotį'
                                      : 'Tikslas įvykdytas'),
                              style: TextStyle(
                                fontSize: 20,
                                color: isDarkMode
                                    ? (widget.goal.sharedGoalModel.user1Id ==
                                            username
                                        ? (!widget.goal.sharedGoalModel
                                                .isCompletedUser1
                                            ? Colors.lightGreen
                                            : Colors.white70)
                                        : (!widget.goal.sharedGoalModel
                                                .isCompletedUser2
                                            ? Colors.lightGreen
                                            : Colors.white70))
                                    : Colors.lightGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                      Text(
                        'Statistika',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.lightGreen[300]
                              : Color(0xFFbcd979),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_currentPage == 0) ...[
                        SizedBox(
                          height: 200,
                          child: goalTasksMine.isEmpty
                              ? Text(
                                  "Nėra progreso duomenų",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey,
                                  ),
                                )
                              : GoalProgressChart(
                                  goal: widget.goal.sharedGoalModel,
                                  goalTasks: goalTasksMine,
                                ),
                        ),
                      ] else if (_currentPage == 1) ...[
                        SizedBox(
                          height: 200,
                          child: goalTasksFriend.isEmpty
                              ? Text(
                                  "Nėra progreso duomenų",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey,
                                  ),
                                )
                              : GoalProgressChart(
                                  goal: widget.goal.sharedGoalModel,
                                  goalTasks: goalTasksFriend,
                                ),
                        ),
                      ] else ...[
                        SizedBox(
                          height: 200,
                          child:
                              (goalTasksMine.isEmpty && goalTasksFriend.isEmpty)
                                  ? Text(
                                      "Nėra progreso duomenų",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.grey[600]
                                            : Colors.grey,
                                      ),
                                    )
                                  : SharedGoalProgressChart(
                                      goal: widget.goal.sharedGoalModel,
                                      goalTasksMine: goalTasksMine,
                                      goalTasksFriend: goalTasksFriend,
                                    ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const BottomNavigation(),
            const SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    List<String> titles = [
      'Mano progresas',
      '${friendName} progresas',
      'Bendras progresas',
    ];

    List<Widget> progressWidgets = [
      buildProgressIndicator(
        _calculateProgress(goalTasksMine, 0),
        widget.goal.sharedGoalModel.plantId,
        _userPoints(goalTasksMine),
        isPlantDeadMine,
        isDarkMode,
      ),
      buildProgressIndicator(
        _calculateProgress(goalTasksFriend, 0),
        widget.goal.sharedGoalModel.plantId,
        _userPoints(goalTasksFriend),
        isPlantDeadFriend,
        isDarkMode,
      ),
      buildProgressIndicator(
        _calculateProgress(goalTasksMine, 1),
        widget.goal.sharedGoalModel.plantId,
        _allPoints(),
        (isPlantDeadMine && isPlantDeadFriend) ? true : false,
        isDarkMode,
      ),
    ];

    return Column(
      children: [
        Text(
          titles[_currentPage],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.lightGreen[300] : Color(0xFF9CBF6E),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 270,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: progressWidgets.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: progressWidgets[index],
              );
            },
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: progressWidgets.length,
          effect: WormEffect(
            dotColor: isDarkMode ? Colors.grey[700]! : Colors.grey.shade400,
            activeDotColor: isDarkMode
                ? Colors.lightGreen[400]!
                : Colors.lightGreen.shade600,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }
}
