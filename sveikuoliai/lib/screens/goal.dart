import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/goal_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
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
      id: '', name: '', points: 0, photoUrl: '', duration: 0, stages: []);
  final PlantService _plantService = PlantService();
  final GoalTaskService _goalTaskService = GoalTaskService();
  final GoalService _goalService = GoalService();
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
    await _fetchPlantData();
    await _fetchGoalTask();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchPlantData() async {
    try {
      PlantModel? fetchedPlant =
          await _plantService.getPlantEntry(widget.goal.goalModel.plantId);
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
      List<GoalTask> tasks =
          await _goalTaskService.getGoalTasks(widget.goal.goalModel.id);

      tasks.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        goalTasks = tasks;
        length = tasks.length;
        doneLength = tasks.where((task) => task.isCompleted).length;
        // Rask naujausią (vėliausią) atliktos užduoties datą
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

      // ✅ Patikriname, ar visos užduotys įvykdytos
      final allCompleted = goalTasks.every((task) => task.isCompleted);
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
                    widget.goal.goalModel.isCompleted = true;
                    _goalService.updateGoalEntry(widget.goal.goalModel);
                    setState(() {
                      widget.goal.goalModel.isCompleted = true;
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
      showCustomSnackBar(
          context,
          "${getPlantName(widget.goal.goalModel.plantId)} bent 2 dienas 🥺",
          false);

      return true;
    } else if (widget.goal.goalModel.plantId == "ramuneles" ||
        widget.goal.goalModel.plantId == "zibuokle" ||
        widget.goal.goalModel.plantId == "saulegraza") {
      if (date.isBefore(threeDaysAgo)) {
        showCustomSnackBar(
            context,
            "${getPlantName(widget.goal.goalModel.plantId)} bent 3 dienas 🥺",
            false);

        return true;
      }
    } else if (widget.goal.goalModel.plantId == "orchideja" ||
        widget.goal.goalModel.plantId == "gervuoge" ||
        widget.goal.goalModel.plantId == "vysnia") {
      if (date.isBefore(weekAgo)) {
        showCustomSnackBar(
            context,
            "${getPlantName(widget.goal.goalModel.plantId)} bent savaitę 🥺",
            false);

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
    //int sum = _userPoints();
    return widget.goal.goalModel.points / widget.goal.goalModel.endPoints;
  }

  int _calculatePoints(bool isCompleted, List<GoalTask> goalTasks) {
    if (isCompleted) {
      return (widget.goal.goalModel.endPoints / goalTasks.length).toInt();
    } else {
      return 0; // Jei užduotis nebaigta, grąžiname 0 taškų
    }
  }

  Future<void> _recalculateGoalTaskPoints() async {
    try {
      // Perkraunam užduotis
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
      showCustomSnackBar(context, "Tikslo užduotis sėkmingai pridėta ✅", true);
      Navigator.pop(context); // Grįžta atgal
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
      await goalService.deleteGoalEntry(
          widget.goal.goalModel.id); // Ištrinti įprotį iš serverio
      // Gali prireikti papildomų veiksmų, pvz., navigacija į kitą ekraną po ištrynimo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 1)),
      ); // Grįžti atgal į pagrindinį ekraną
      showCustomSnackBar(context, "Tikslas sėkmingai ištrintas ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant tikslą ❌", false);
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
                margin:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                                        HabitsGoalsScreen(selectedIndex: 1)),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 30,
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
                                    accentColor: Colors.lightBlueAccent,
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
                                entityType: EntityType.goal,
                                entity: widget.goal,
                                accentColor: Colors.lightBlueAccent,
                                onDelete: () {
                                  _deleteGoal();
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
                          color: Color(0xFF72ddf7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      buildProgressIndicator(
                        _calculateProgress(),
                        widget.goal.goalModel.plantId,
                        widget.goal.goalModel.points,
                        widget.goal.goalModel.isPlantDead,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Apie tikslą',
                        style:
                            TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
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
                            style: const TextStyle(
                                fontSize: 18, color: Color(0xFF72ddf7)),
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
                                .format(widget.goal.goalModel.startDate),
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF72ddf7)),
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
                                .format(widget.goal.goalModel.endDate),
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF72ddf7)),
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
                                fontSize: 18, color: Color(0xFF72ddf7)),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Užduotys',
                        style:
                            TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  )),
                          ...goalTasks.where((task) => task.isCompleted).map(
                              (task) => GoalTaskCard(
                                  type: 0,
                                  task: task,
                                  isDoneGoal: widget.goal.goalModel.isCompleted,
                                  isMyTask: true,
                                  length: length,
                                  doneLength: doneLength,
                                  calculatePoints: (isCompleted) =>
                                      _calculatePoints(
                                          isCompleted, goalTasks))),
                        ],
                      ),
                      if (widget.goal.goalModel.isCompleted == false)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (goalTasks
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
                                          return const Color(0xFFCFF4FC);
                                        },
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blue),
                                    ),
                                    child: const Text(
                                      'Išsaugoti',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: widget.goal.goalModel.isCompleted
                            ? null
                            : () {
                                CustomDialogs.showNewTaskDialog(
                                  context: context,
                                  goal: widget.goal,
                                  accentColor: Colors.lightBlueAccent,
                                  onSave: (GoalTask task) {
                                    _createTask(task);
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              const Color(0xFFA5E9F9), // Šviesi mėlyna spalva
                          foregroundColor:
                              Colors.blue, // Teksto ir ikonos spalva
                        ),
                        child: Text(
                          widget.goal.goalModel.isCompleted
                              ? 'Tiklas įvykdytas'
                              : 'Pridėti užduotį',
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Statistika',
                        style:
                            TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
                      ),
                      // SizedBox(height: 200, child: _buildChart()),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: goalTasks.isEmpty
                            ? Text("Nėra progreso duomenų",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey))
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
