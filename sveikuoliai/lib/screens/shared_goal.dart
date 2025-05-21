import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
import 'package:sveikuoliai/services/user_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_dialogs.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/goal_task_card.dart';
import 'package:sveikuoliai/widgets/progress_indicator.dart';

class SharedGoalScreen extends StatefulWidget {
  final SharedGoalInformation goal;
  const SharedGoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  _SharedGoalPageState createState() => _SharedGoalPageState();
}

class _SharedGoalPageState extends State<SharedGoalScreen> {
  PlantModel plant = PlantModel(
      id: '', name: '', points: 0, photoUrl: '', duration: 0, stages: []);
  final PlantService _plantService = PlantService();
  final GoalTaskService _goalTaskService = GoalTaskService();
  final SharedGoalService _sharedGoalService = SharedGoalService();
  final AuthService _authService = AuthService(); // Pridėta AuthService
  final UserService _userService = UserService(); // Pridėta UserService
  List<GoalTask> goalTasksMine = [];
  List<GoalTask> goalTasksFriend = []; // Užduočių sąrašas
  int _currentPage = 0; // Puslapio indeksas
  PageController _pageController = PageController();
  int lengthMine = 0;
  int doneLengthMine = 0; // Užbaigtų užduočių skaičius
  int lengthFriend = 0;
  int doneLengthFriend = 0; // Užbaigtų užduočių skaičius
  String friendUsername = ''; // Draugo vartotojo vardas
  String friendName = ''; // Draugo vardas
  String username = ''; // Vartotojo vardas
  bool isPlantDeadMine = false; // Augalo būsena
  bool isPlantDeadFriend = false; // Draugo augalo būsena
  late DateTime lastDoneDate;
  late DateTime lastDoneDateFriend;

  @override
  void initState() {
    super.initState();
    lastDoneDate = widget.goal.sharedGoalModel.startDate;
    lastDoneDateFriend = widget.goal.sharedGoalModel.startDate;
    _loadData();
  }

  // Funkcija duomenims užkrauti
  Future<void> _loadData() async {
    await _fetchSessionUser(); // Gauti prisijungusio vartotojo duomenis
    await _fetchPlantData();
    await _fetchGoalTask();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchSessionUser() async {
    // Patikrinti, ar sesijoje jau yra duomenų
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
        });
      } catch (e) {
        setState(() {
          username = "Klaida gaunant duomenis";
        });
      }
    }
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchPlantData() async {
    try {
      PlantModel? fetchedPlant = await _plantService
          .getPlantEntry(widget.goal.sharedGoalModel.plantId);
      if (fetchedPlant != null) {
        setState(() {
          plant = fetchedPlant;
        });
      } else {
        throw Exception("Gautas `null` augalo objektas");
      }
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

      tasksMine.sort((a, b) => a.date.compareTo(b.date));
      tasksFriend.sort((a, b) => a.date.compareTo(b.date));

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
      bool isDeadFriend = isPlantDead(lastDoneDateFriend, false);
      setState(() {
        widget.goal.sharedGoalModel.isPlantDeadUser2 = isDeadFriend;
        isPlantDeadFriend = isDeadFriend;
      });
      await _sharedGoalService
          .updateSharedGoalEntry(widget.goal.sharedGoalModel);
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

      // ✅ Patikriname, ar visos užduotys įvykdytos
      final allCompleted = goalTasksMine.every((task) => task.isCompleted);
      if (allCompleted) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Sveikiname! 🎉"),
              content: const Text(
                  "Įvykdėte visas užduotis. Ką norėtumėte daryti toliau?"),
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
                  child: const Text("Užbaigti tikslą"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    CustomDialogs.showNewFirstTaskDialog(
                      context: context,
                      type: 1,
                      onSave: (newTask) => _createTask(newTask),
                      goal: widget.goal,
                      accentColor: Colors.lightBlueAccent,
                    );
                  },
                  child: const Text("Pridėti užduotį"),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          showCustomSnackBar(
              context, "Tikslo būsena sėkmingai išsaugota ✅", true);
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
        showCustomSnackBar(
            context,
            "${getPlantName(widget.goal.sharedGoalModel.plantId)} bent 2 dienas 🥺",
            false);
      }
      return true;
    } else if (widget.goal.sharedGoalModel.plantId == "ramuneles" ||
        widget.goal.sharedGoalModel.plantId == "zibuokle" ||
        widget.goal.sharedGoalModel.plantId == "saulegraza") {
      if (date.isBefore(threeDaysAgo)) {
        if (isMine) {
          showCustomSnackBar(
              context,
              "${getPlantName(widget.goal.sharedGoalModel.plantId)} bent 3 dienas 🥺",
              false);
        }
        return true;
      }
    } else if (widget.goal.sharedGoalModel.plantId == "orchideja" ||
        widget.goal.sharedGoalModel.plantId == "gervuoge" ||
        widget.goal.sharedGoalModel.plantId == "vysnia") {
      if (date.isBefore(weekAgo)) {
        if (isMine) {
          showCustomSnackBar(
              context,
              "${getPlantName(widget.goal.sharedGoalModel.plantId)} bent savaitę 🥺",
              false);
        }
        return true;
      }
    }
    return false;
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
    return (sum / 2).toInt(); // Grąžina bendrą taškų skaičių
  }

  int _userPoints(List<GoalTask> goalTasks) {
    int sum = 0;
    for (var task in goalTasks) {
      sum += task.points;
    }
    return sum;
  }

  double _calculateProgress(List<GoalTask> goalTasks, int flag) {
    if (widget.goal.sharedGoalModel.endPoints == 0)
      return 0.0; // Apsauga nuo dalybos iš nulio
    //int sum = _userPoints();
    return flag == 0
        ? _userPoints(goalTasks) / widget.goal.sharedGoalModel.endPoints
        : _allPoints() / widget.goal.sharedGoalModel.endPoints;
  }

  int _calculatePoints(bool isCompleted, List<GoalTask> goalTasks) {
    if (isCompleted) {
      return (widget.goal.sharedGoalModel.endPoints / goalTasks.length).toInt();
    } else {
      return 0; // Jei užduotis nebaigta, grąžiname 0 taškų
    }
  }

  Future<void> _recalculateGoalTaskPoints() async {
    try {
      // Perkraunam užduotis
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
      await _recalculateGoalTaskPoints(); // Perskaičiuojame taškus
      showCustomSnackBar(
          context, "Draugų tikslo užduotis sėkmingai pridėta ✅", true);
      Navigator.pop(context); // Grįžta atgal
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
      await goalService.deleteSharedGoalEntry(
          widget.goal.sharedGoalModel.id); // Ištrinti įprotį iš serverio
      // Gali prireikti papildomų veiksmų, pvz., navigacija į kitą ekraną po ištrynimo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 2)),
      ); // Grįžti atgal į pagrindinį ekraną
      showCustomSnackBar(context, "Draugų tikslas sėkmingai ištrintas ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant draugų tikslą ❌", false);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final taskService = GoalTaskService();
      await taskService
          .deleteGoalTaskEntry(taskId); // Ištrinti įprotį iš serverio
      await _recalculateGoalTaskPoints(); // Perskaičiuojame taškus
      //Navigator.pop(context); // Grįžta atgal
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
    // Fiksuoti tarpai
    const double topPadding = 25.0; // Tarpas nuo viršaus
    const double horizontalPadding = 20.0; // Tarpai iš šonų
    const double bottomPadding =
        20.0; // Tarpas nuo apačios (virš BottomNavigation)

    // Gauname ekrano matmenis
    //final Size screenSize = MediaQuery.of(context).size;

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
                margin: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 20),
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
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 30,
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
                                    accentColor: Colors.lightGreen[400] ??
                                        Colors.lightGreen,
                                    onSave: () {});
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 30,
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              CustomDialogs.showDeleteDialog(
                                context: context,
                                entityType: EntityType.sharedGoal,
                                entity: widget.goal,
                                accentColor: Colors.lightGreen,
                                onDelete: () {
                                  _deleteGoal(); // Ištrinti tikslą
                                },
                              );
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
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
                          color: Color(0xFFbcd979),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      _buildBanner(),
                      const SizedBox(height: 20),
                      const Text(
                        'Apie tikslą',
                        style:
                            TextStyle(fontSize: 25, color: Color(0xFFbcd979)),
                      ),
                      Text(
                        widget.goal.goalType.description,
                        style: const TextStyle(fontSize: 18),
                        softWrap: true, // Leisti tekstui kelti į kitą eilutę
                        overflow: TextOverflow.visible, // Nesutrumpinti teksto
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Trukmė: ',
                            style: TextStyle(fontSize: 18),
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
                            style: const TextStyle(
                                fontSize: 18, color: Color(0xFFbcd979)),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Pradžios data: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            DateFormat('yyyy MMMM d', 'lt')
                                .format(widget.goal.sharedGoalModel.startDate),
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFFbcd979)),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Pabaigos data: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            DateFormat('yyyy MMMM d', 'lt')
                                .format(widget.goal.sharedGoalModel.endDate),
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFFbcd979)),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Augaliukas: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            plant.name,
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFFbcd979)),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (_currentPage != 2) ...[
                        Text(
                          'Užduotys',
                          style:
                              TextStyle(fontSize: 25, color: Color(0xFFbcd979)),
                        ),
                      ],
                      if (_currentPage == 0) // Mano progresas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  ),
                                ),
                          ],
                        )
                      else if (_currentPage == 1) // Draugo progresas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    onDelete:
                                        null, // Draugo užduočių trinti negalima
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
                                  ),
                                ),
                          ],
                        )
                      else // Bendras progresas
                        const SizedBox.shrink(),
                      if (_currentPage == 2 &&
                          widget.goal.sharedGoalModel.isCompletedUser1 &&
                          widget.goal.sharedGoalModel.isCompletedUser2) ...[
                        const Text(
                          'Įvykdėte bendrą tikslą!',
                          style:
                              TextStyle(fontSize: 25, color: Colors.lightGreen),
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
                              if (goalTasksMine
                                  .isNotEmpty) // Patikriname, ar yra užduočių
                                ElevatedButton(
                                  onPressed: () async {
                                    await _saveGoalStates(); // Pirma išsaugome duomenis
                                    if (mounted) {
                                      setState(
                                          () {}); // Tada atnaujiname ekraną
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        return const Color(0xFFECFFC5);
                                      },
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                        Colors.lightGreen),
                                  ),
                                  child: const Text(
                                    'Išsaugoti',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed:
                                !widget.goal.sharedGoalModel.isCompletedUser1
                                    ? null
                                    : () {
                                        CustomDialogs.showNewTaskDialog(
                                          context: context,
                                          goal: widget.goal,
                                          accentColor: Colors.lightGreen[400] ??
                                              Colors.lightGreen,
                                          onSave: (GoalTask task) {
                                            _createTask(task);
                                          },
                                        );
                                      },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(
                                  0xFFE4F7B4), // Šviesi mėlyna spalva
                              foregroundColor:
                                  Colors.lightGreen, // Teksto ir ikonos spalva
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
                                  fontSize: 20, color: Colors.lightGreen),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                      const Text(
                        'Statistika',
                        style:
                            TextStyle(fontSize: 25, color: Color(0xFFbcd979)),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(height: 200, child: _buildChart()),
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
      '${friendName} progresas', // friendName yra tavo draugo vardas
      'Bendras progresas',
    ];

    List<Widget> progressWidgets = [
      buildProgressIndicator(
        _calculateProgress(goalTasksMine, 0),
        widget.goal.sharedGoalModel.plantId,
        _userPoints(goalTasksMine),
        isPlantDeadMine,
      ),
      buildProgressIndicator(
        _calculateProgress(goalTasksFriend, 0),
        widget.goal.sharedGoalModel.plantId,
        _userPoints(goalTasksFriend),
        isPlantDeadFriend,
      ),
      buildProgressIndicator(
        _calculateProgress(goalTasksMine, 1),
        widget.goal.sharedGoalModel.plantId,
        _allPoints(),
        (isPlantDeadMine && isPlantDeadFriend) ? true : false,
      ),
    ];

    return Column(
      children: [
        // Dinamiškas tekstas pagal pasirinktą puslapį
        Text(
          titles[_currentPage],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9CBF6E), // Slightly darker green
          ),
        ),
        SizedBox(height: 10),
        // Progreso slankiklis (karuselė)
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
        // Indikatoriai (taškai)
        SmoothPageIndicator(
          controller: _pageController,
          count: progressWidgets.length,
          effect: WormEffect(
            dotColor: Colors.grey.shade400,
            activeDotColor: Colors.lightGreen.shade600,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 5),
                FlSpot(4, 4),
                FlSpot(5, 6),
              ],
              isCurved: true,
              color: const Color(0xFFbcd979),
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFbcd979).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
