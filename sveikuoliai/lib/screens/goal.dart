import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/goal_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_dialogs.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/goal_progress_graph.dart';
import 'package:sveikuoliai/widgets/goal_task_card.dart';
import 'package:sveikuoliai/widgets/progress_indicator.dart';

class GoalScreen extends StatefulWidget {
  final GoalInformation goal;
  const GoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalScreen> {
  PlantModel plant = PlantModel(
    id: '',
    name: '',
    points: 0,
    photoUrl: '',
    duration: 0,
  );
  final GoalTaskService _goalTaskService = GoalTaskService();
  final GoalService _goalService = GoalService();
  final AuthService _authService = AuthService(); // Pridėtas AuthService
  bool isDarkMode = false; // Temos būsena
  List<GoalTask> goalTasks = [];
  int length = 0;
  int doneLength = 0;
  late DateTime lastDoneDate;

  @override
  void initState() {
    super.initState();
    lastDoneDate = widget.goal.goalModel.startDate;
    _loadData();
  }

  // Funkcija duomenims užkrauti
  Future<void> _loadData() async {
    await _fetchUserData(); // Pridėta sesijos duomenų gavimas
    await _fetchPlantData();
    await _fetchGoalTask();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchUserData() async {
    try {
      Map<String, String?> sessionData = await _authService.getSessionUser();
      if (!mounted) return; // Apsauga prieš setState
      setState(() {
        isDarkMode = sessionData['darkMode'] == 'true'; // Gauname darkMode
      });
    } catch (e) {
      if (mounted) {
        String message = 'Klaida gaunant duomenis ❌';
        showCustomSnackBar(context, message, false);
      }
    }
  }

  Future<void> _fetchPlantData() async {
    try {
      List<PlantModel> plants = await _authService.getPlantsFromSession();
      PlantModel? fetchedPlant = plants.firstWhere(
        (p) => p.id == widget.goal.goalModel.plantId,
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
      List<GoalTask> tasks =
          await _goalTaskService.getGoalTasks(widget.goal.goalModel.id);

      tasks.sort((a, b) {
        int getNumericId(String id) {
          final match = RegExp(r'^(\d+)_').firstMatch(id);
          if (match != null) {
            return int.tryParse(match.group(1)!) ?? 0;
          }
          return -1; // -1 reiškia nėra skaičiaus pradžioje
        }

        int aNum = getNumericId(a.id);
        int bNum = getNumericId(b.id);

        if (aNum != -1 && bNum != -1) {
          // Abu turi skaičių pradžioje – rikiuojam pagal skaičių
          return aNum.compareTo(bNum);
        } else if (aNum == -1 && bNum == -1) {
          // Abu neturi skaičiaus – rikiuojam pagal datą
          return a.date.compareTo(b.date);
        } else if (aNum == -1) {
          // a neturi skaičiaus, b turi – a eina po b
          return 1;
        } else {
          // b neturi skaičiaus, a turi – a eina prieš b
          return -1;
        }
      });

      setState(() {
        goalTasks = tasks;
        length = tasks.length;
        doneLength = tasks.where((task) => task.isCompleted).length;
        final completedTasks = tasks.where((task) => task.isCompleted).toList();
        if (completedTasks.isNotEmpty) {
          lastDoneDate = completedTasks
              .map((task) => task.date)
              .reduce((a, b) => a.isAfter(b) ? a : b);
        }
      });
      if (!widget.goal.goalModel.isCompleted) {
        bool isDead = await isPlantDead(lastDoneDate);
        setState(() {
          widget.goal.goalModel.isPlantDead = isDead;
        });
        await _goalService.updateGoalEntry(widget.goal.goalModel);

        // Atnaujiname sesiją su naujausiais duomenimis
        List<GoalInformation> goals = await _authService.getGoalsFromSession();
        int goalIndex =
            goals.indexWhere((g) => g.goalModel.id == widget.goal.goalModel.id);
        if (goalIndex != -1) {
          goals[goalIndex] = widget.goal; // Atnaujiname esamą tikslą
        } else {
          goals.add(widget.goal); // Jei tikslo dar nėra, pridedame
        }
        await _authService.saveGoalsToSession(goals);
      }
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant tikslo užduotis ❌', false);
    }
  }

  Future<void> _saveGoalStates() async {
    try {
      for (var task in goalTasks) {
        await _goalTaskService.updateGoalTaskState(
          task.id,
          task.isCompleted,
          task.points,
        );
      }
      await _goalService.updateGoalPoints(
          widget.goal.goalModel.id, _userPoints());
      setState(() {
        widget.goal.goalModel.points = _userPoints();
      });

      // Atnaujiname sesiją su naujausiais duomenimis
      List<GoalInformation> goals = await _authService.getGoalsFromSession();
      int goalIndex =
          goals.indexWhere((g) => g.goalModel.id == widget.goal.goalModel.id);
      if (goalIndex != -1) {
        goals[goalIndex] = widget.goal; // Atnaujiname esamą tikslą
      } else {
        goals.add(widget.goal); // Jei tikslo dar nėra, pridedame
      }
      await _authService.saveGoalsToSession(goals);

      final allCompleted = goalTasks.every((task) => task.isCompleted);
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
                  onPressed: () async {
                    Navigator.pop(context);
                    widget.goal.goalModel.isCompleted = true;
                    _goalService.updateGoalEntry(widget.goal.goalModel);
                    setState(() {
                      widget.goal.goalModel.isCompleted = true;
                    });
                    // Atnaujiname sesiją po užbaigimo
                    List<GoalInformation> updatedGoals =
                        await _authService.getGoalsFromSession();
                    int updatedIndex = updatedGoals.indexWhere(
                        (g) => g.goalModel.id == widget.goal.goalModel.id);
                    if (updatedIndex != -1) {
                      updatedGoals[updatedIndex] = widget.goal;
                      await _authService.saveGoalsToSession(updatedGoals);
                    }
                    showCustomSnackBar(
                        context, "Tikslas sėkmingai užbaigtas ✅", true);
                  },
                  child: Text(
                    "Užbaigti tikslą",
                    style: TextStyle(
                      color: isDarkMode ? Colors.lightBlue[300] : Colors.blue,
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
                          ? Colors.lightBlue[300]!
                          : Colors.lightBlueAccent,
                    );
                  },
                  child: Text(
                    "Pridėti užduotį",
                    style: TextStyle(
                      color: isDarkMode ? Colors.lightBlue[300] : Colors.blue,
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
              builder: (context) => GoalScreen(
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

  Future<bool> isPlantDead(DateTime date) async {
    DateTime today = DateTime.now();
    DateTime twoDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 2));
    DateTime threeDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 3));
    DateTime weekAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 7));
    if (widget.goal.goalModel.plantId == "dobiliukas" &&
        date.isBefore(twoDaysAgo)) {
      showCustomPlantSnackBar(
        context,
        "${getPlantName(widget.goal.goalModel.plantId)} bent 2 dienas 🥺",
      );

      return true;
    } else if (widget.goal.goalModel.plantId == "ramuneles" ||
        widget.goal.goalModel.plantId == "zibuokle" ||
        widget.goal.goalModel.plantId == "saulegraza") {
      if (date.isBefore(threeDaysAgo)) {
        showCustomPlantSnackBar(context,
            "${getPlantName(widget.goal.goalModel.plantId)} bent 3 dienas 🥺");

        return true;
      }
    } else if (widget.goal.goalModel.plantId == "orchideja" ||
        widget.goal.goalModel.plantId == "gervuoge" ||
        widget.goal.goalModel.plantId == "vysnia") {
      if (date.isBefore(weekAgo)) {
        showCustomPlantSnackBar(
          context,
          "${getPlantName(widget.goal.goalModel.plantId)} bent savaitę 🥺",
        );

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
      backgroundColor: Colors.lightBlue.shade400.withOpacity(0.6),
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

  int _userPoints() {
    int sum = 0;
    for (var task in goalTasks) {
      sum += task.points;
    }
    return sum;
  }

  double _calculateProgress() {
    if (widget.goal.goalModel.endPoints == 0)
      return 0.0; // Apsauga nuo dalybos iš nulio
    return widget.goal.goalModel.points / widget.goal.goalModel.endPoints;
  }

  int _calculatePoints(bool isCompleted, List<GoalTask> goalTasks) {
    if (isCompleted) {
      return (widget.goal.goalModel.endPoints / goalTasks.length).toInt();
    } else {
      return 0;
    }
  }

  Future<void> _recalculateGoalTaskPoints() async {
    try {
      List<GoalTask> updatedTasks =
          await _goalTaskService.getGoalTasks(widget.goal.goalModel.id);
      print('kiek užduočių: ${updatedTasks.length}');

      for (var task in updatedTasks) {
        int points = _calculatePoints(task.isCompleted, updatedTasks);
        await _goalTaskService.updateGoalTaskState(
          task.id,
          task.isCompleted,
          points,
        );
      }
      updatedTasks =
          await _goalTaskService.getGoalTasks(widget.goal.goalModel.id);

      setState(() {
        goalTasks = updatedTasks;
        length = updatedTasks.length;
        doneLength = updatedTasks.where((task) => task.isCompleted).length;
      });

      int totalPoints = _userPoints();
      print("Total points: $totalPoints");

      await _goalService.updateGoalPoints(
          widget.goal.goalModel.id, totalPoints);

      setState(() {
        widget.goal.goalModel.points = totalPoints;
      });

      // Atnaujiname sesiją po užbaigimo
      List<GoalInformation> updatedGoals =
          await _authService.getGoalsFromSession();
      int updatedIndex = updatedGoals
          .indexWhere((g) => g.goalModel.id == widget.goal.goalModel.id);
      if (updatedIndex != -1) {
        updatedGoals[updatedIndex] = widget.goal;
        await _authService.saveGoalsToSession(updatedGoals);
      }
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
      //showCustomSnackBar(context, "Tikslo užduotis sėkmingai pridėta ✅", true);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GoalScreen(
                  goal: widget.goal,
                )),
      );
    } catch (e) {
      showCustomSnackBar(context, "Klaida pridedant tikslo užduotį ❌", false);
    }
  }

  Future<void> _deleteGoal() async {
    try {
      final goalService = GoalService();
      await goalService.deleteGoalEntry(widget.goal.goalModel.id);
      await _authService.removeGoalFromSession(widget.goal);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 1)),
      );
      showCustomSnackBar(context, "Tikslas sėkmingai ištrintas ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant tikslą ❌", false);
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
            builder: (context) => GoalScreen(
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
                                        HabitsGoalsScreen(selectedIndex: 1)),
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
                              widget.goal.goalModel.isCompleted == false)
                            IconButton(
                              onPressed: () {
                                CustomDialogs.showEditDialog(
                                  context: context,
                                  entityType: EntityType.goal,
                                  entity: widget.goal,
                                  accentColor: isDarkMode
                                      ? Colors.lightBlue[300]!
                                      : Colors.lightBlueAccent,
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
                                entityType: EntityType.goal,
                                entity: widget.goal,
                                accentColor: isDarkMode
                                    ? Colors.lightBlue[300]!
                                    : Colors.lightBlueAccent,
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
                              ? Colors.lightBlue[300]
                              : Color(0xFF72ddf7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      buildProgressIndicator(
                        _calculateProgress(),
                        widget.goal.goalModel.plantId,
                        widget.goal.goalModel.points,
                        widget.goal.goalModel.isPlantDead,
                        isDarkMode,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Apie tikslą',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.lightBlue[300]
                              : Color(0xFF72ddf7),
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
                            widget.goal.goalModel.endPoints == 7
                                ? "1 savaitė"
                                : widget.goal.goalModel.endPoints == 14
                                    ? "2 savaitės"
                                    : widget.goal.goalModel.endPoints == 30
                                        ? "1 mėnuo"
                                        : widget.goal.goalModel.endPoints == 45
                                            ? "1,5 mėnesio"
                                            : widget.goal.goalModel.endPoints ==
                                                    60
                                                ? "2 mėnesiai"
                                                : widget.goal.goalModel
                                                            .endPoints ==
                                                        90
                                                    ? "3 mėnesiai"
                                                    : "6 mėnesiai",
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightBlue[300]
                                  : Color(0xFF72ddf7),
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
                                .format(widget.goal.goalModel.startDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightBlue[300]
                                  : Color(0xFF72ddf7),
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
                                .format(widget.goal.goalModel.endDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.lightBlue[300]
                                  : Color(0xFF72ddf7),
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
                                  ? Colors.lightBlue[300]
                                  : Color(0xFF72ddf7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Užduotys',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.lightBlue[300]
                              : Color(0xFF72ddf7),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (goalTasks.isEmpty)
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
                          ...goalTasks
                              .where((task) => !task.isCompleted)
                              .map((task) => GoalTaskCard(
                                    task: task,
                                    type: 0,
                                    isDoneGoal:
                                        widget.goal.goalModel.isCompleted,
                                    isMyTask: true,
                                    length: length,
                                    doneLength: doneLength,
                                    calculatePoints: (isCompleted) =>
                                        _calculatePoints(
                                            isCompleted, goalTasks),
                                    onDelete: _deleteTask,
                                    isDarkMode:
                                        isDarkMode, // Perduodame isDarkMode
                                  )),
                          ...goalTasks
                              .where((task) => task.isCompleted)
                              .map((task) => GoalTaskCard(
                                    type: 0,
                                    task: task,
                                    isDoneGoal:
                                        widget.goal.goalModel.isCompleted,
                                    isMyTask: true,
                                    length: length,
                                    doneLength: doneLength,
                                    calculatePoints: (isCompleted) =>
                                        _calculatePoints(
                                            isCompleted, goalTasks),
                                    isDarkMode:
                                        isDarkMode, // Perduodame isDarkMode
                                  )),
                        ],
                      ),
                      if (widget.goal.goalModel.isCompleted == false)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (goalTasks.isNotEmpty)
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
                                              : const Color(0xFFCFF4FC);
                                        },
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                        isDarkMode ? Colors.white : Colors.blue,
                                      ),
                                    ),
                                    child: Text(
                                      'Išsaugoti',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: widget.goal.goalModel.isCompleted
                            ? null
                            : () {
                                CustomDialogs.showNewTaskDialog(
                                  context: context,
                                  goal: widget.goal,
                                  accentColor: isDarkMode
                                      ? Colors.lightBlue[300]!
                                      : Colors.lightBlueAccent,
                                  onSave: (GoalTask task) {
                                    _createTask(task);
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: isDarkMode
                              ? (widget.goal.goalModel.isCompleted
                                  ? Colors.grey[700]
                                  : Colors.white)
                              : (widget.goal.goalModel.isCompleted
                                  ? Colors.grey
                                  : const Color(0xFFA5E9F9)),
                          foregroundColor:
                              isDarkMode ? Colors.black : Colors.blue,
                        ),
                        child: Text(
                          widget.goal.goalModel.isCompleted
                              ? 'Tiklas įvykdytas'
                              : 'Pridėti užduotį',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode
                                ? (widget.goal.goalModel.isCompleted
                                    ? Colors.white70
                                    : Colors.blue)
                                : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Statistika',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.lightBlue[300]
                              : Color(0xFF72ddf7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: goalTasks.isEmpty
                            ? Text(
                                "Nėra progreso duomenų",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey,
                                ),
                              )
                            : _buildProgressChart(),
                      ),
                    ],
                  ),
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

  Widget _buildProgressChart() {
    return GoalProgressChart(
      goal: widget.goal.goalModel,
      goalTasks: goalTasks,
    );
  }
}
