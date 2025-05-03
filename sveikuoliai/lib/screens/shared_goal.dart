import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
import 'package:sveikuoliai/services/shared_goal_services.dart';
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
  List<GoalTask> goalTasks = [];
  int length = 0;
  int doneLength = 0; // Užbaigtų užduočių skaičius

  @override
  void initState() {
    super.initState();
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
      List<GoalTask> tasks =
          await _goalTaskService.getGoalTasks(widget.goal.sharedGoalModel.id);

      setState(() {
        goalTasks = tasks;
        length = tasks.length;
        doneLength = tasks.where((task) => task.isCompleted).length;
      });
    } catch (e) {
      showCustomSnackBar(
          context, 'Klaida kraunant draugų tikslo užduotis ❌', false);
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
      await _sharedGoalService.updateGoalPoints(
          widget.goal.sharedGoalModel.id, _userPoints());

      setState(() {
        widget.goal.sharedGoalModel.points = _userPoints();
      });

      if (mounted) {
        showCustomSnackBar(
            context, "Bendro tikslo būsena sėkmingai išsaugota ✅", true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            context, "Klaida išsaugant bendro tikslo būseną ❌", false);
      }
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
    if (widget.goal.sharedGoalModel.endPoints == 0)
      return 0.0; // Apsauga nuo dalybos iš nulio
    //int sum = _userPoints();
    return widget.goal.sharedGoalModel.points /
        widget.goal.sharedGoalModel.endPoints;
  }

  int _calculatePoints(bool isCompleted) {
    if (isCompleted) {
      return (widget.goal.sharedGoalModel.endPoints / goalTasks.length).toInt();
    } else {
      return 0; // Jei užduotis nebaigta, grąžiname 0 taškų
    }
  }

  Future<void> _createTask(GoalTask task) async {
    try {
      await _goalTaskService.createGoalTaskEntry(task);
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
        MaterialPageRoute(builder: (context) => HabitsGoalsScreen()),
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
                                  builder: (context) => HabitsGoalsScreen()),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        if (widget.goal.goalType.type == 'custom')
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
                    const SizedBox(height: 20),
                    buildProgressIndicator(
                      _calculateProgress(),
                      widget.goal.sharedGoalModel.plantId,
                      widget.goal.sharedGoalModel.points,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Apie tikslą',
                      style: TextStyle(fontSize: 25, color: Color(0xFFbcd979)),
                    ),
                    Text(
                      widget.goal.goalType.description,
                      style: const TextStyle(fontSize: 18),
                      softWrap: true, // Leisti tekstui kelti į kitą eilutę
                      overflow: TextOverflow.visible, // Nesutrumpinti teksto
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
                                  : widget.goal.sharedGoalModel.endPoints == 30
                                      ? "1 mėnuo"
                                      : widget.goal.sharedGoalModel.endPoints ==
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
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFbcd979)),
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
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFbcd979)),
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
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFbcd979)),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Užduotys',
                      style: TextStyle(fontSize: 25, color: Color(0xFFbcd979)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...goalTasks
                            .where((task) => !task.isCompleted)
                            .map((task) => GoalTaskCard(
                                  task: task,
                                  type: 1,
                                  length: length,
                                  doneLength: doneLength,
                                  calculatePoints: _calculatePoints,
                                  onDelete: _deleteTask,
                                )),
                        ...goalTasks
                            .where((task) => task.isCompleted)
                            .map((task) => GoalTaskCard(
                                  task: task,
                                  type: 1,
                                  length: length,
                                  doneLength: doneLength,
                                  calculatePoints: _calculatePoints,
                                )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (goalTasks
                            .isNotEmpty) // Patikriname, ar yra užduočių
                          ElevatedButton(
                            onPressed: () async {
                              await _saveGoalStates(); // Pirma išsaugome duomenis
                              if (mounted) {
                                setState(() {}); // Tada atnaujiname ekraną
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  return const Color(0xFFECFFC5);
                                },
                              ),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.lightGreen),
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
                      onPressed: () {
                        CustomDialogs.showNewTaskDialog(
                          context: context,
                          goal: widget.goal,
                          accentColor:
                              Colors.lightGreen[400] ?? Colors.lightGreen,
                          onSave: (GoalTask task) {
                            _createTask(task);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            const Color(0xFFE4F7B4), // Šviesi mėlyna spalva
                        foregroundColor:
                            Colors.lightGreen, // Teksto ir ikonos spalva
                      ),
                      child: const Text(
                        'Pridėti užduotį',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Statistika',
                      style: TextStyle(fontSize: 25, color: Color(0xFFbcd979)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: 200, child: _buildChart()),
                  ],
                ),
              ),
            ),
            const BottomNavigation(),
          ],
        ),
      ),
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
