import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/goal_services.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/goal_type_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

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

      setState(() {
        goalTasks = tasks;
        length = tasks.length;
      });
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

      if (mounted) {
        showCustomSnackBar(
            context, "Tikslo būsena sėkmingai išsaugota ✅", true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Klaida išsaugant tikslo būseną ❌", false);
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
    if (widget.goal.goalModel.endPoints == 0)
      return 0.0; // Apsauga nuo dalybos iš nulio
    //int sum = _userPoints();
    return widget.goal.goalModel.points / widget.goal.goalModel.endPoints;
  }

  int _calculatePoints() {
    return (widget.goal.goalModel.endPoints / goalTasks.length).toInt();
  }

  Future<void> _createTask(GoalTask task) async {
    try {
      await _goalTaskService.createGoalTaskEntry(task);
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
        MaterialPageRoute(builder: (context) => HabitsGoalsScreen()),
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
                              _showCustomGoalDialog(context);
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 30,
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            // Rodyti dialogą su klausimu
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text.rich(
                                    TextSpan(
                                      text:
                                          "${widget.goal.goalType.title}\n", // Pirmoji dalis (pavadinimas)
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors
                                              .deepPurple), // Pavadinimo stilius
                                      children: [
                                        TextSpan(
                                          text:
                                              "Ar tikrai norite ištrinti šį tikslą?", // Antra dalis
                                          style: TextStyle(
                                            fontWeight: FontWeight
                                                .normal, // Normalus svoris
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: Text(
                                      "Šio tikslo ištrynimas bus negrįžtamas."),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Centruoja mygtukus
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // Uždaro dialogą (Ne pasirinkimas)
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.deepPurple
                                                .withOpacity(
                                                    0.2), // Neryškus fonas
                                          ),
                                          child: Text(
                                            "Ne",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 20), // Tarpas tarp mygtukų
                                        TextButton(
                                          onPressed: () {
                                            _deleteGoal(); // Ištrina įprotį
                                            Navigator.pop(
                                                context); // Uždarome dialogą
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.red
                                                .withOpacity(
                                                    0.2), // Neryškus fonas
                                          ),
                                          child: Text(
                                            "Taip",
                                            style: TextStyle(
                                              color: Colors.red,
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
                    ),
                    const SizedBox(height: 20),
                    _buildProgressIndicator(
                      _calculateProgress(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Apie tikslą',
                      style: TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
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
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF72ddf7)),
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
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF72ddf7)),
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
                              TextStyle(fontSize: 18, color: Color(0xFF72ddf7)),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Užduotys',
                      style: TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...goalTasks
                            .where((task) => !task.isCompleted)
                            .map((task) => _buildGoalItemFalse(task, length)),
                        ...goalTasks
                            .where((task) => task.isCompleted)
                            .map(_buildGoalItemTrue),
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
                                  return const Color(0xFFCFF4FC);
                                },
                              ),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.blue),
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String taskTitle = '';
                            String taskDescription = '';
                            return AlertDialog(
                              title: const Text('Pridėti užduotį'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      taskTitle = value;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Pavadinimas',
                                    ),
                                  ),
                                  TextField(
                                    onChanged: (value) {
                                      taskDescription = value;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Aprašymas',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Atšaukti'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      GoalTask task = GoalTask(
                                        id: '${widget.goal.goalModel.goalTypeId}${widget.goal.goalModel.userId[0].toUpperCase() + widget.goal.goalModel.userId.substring(1)}${DateTime.now()}',
                                        title: taskTitle,
                                        description: taskDescription,
                                        goalId: widget.goal.goalModel.id,
                                        date: DateTime.now(),
                                      );
                                      _createTask(task);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Pridėti'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            const Color(0xFFA5E9F9), // Šviesi mėlyna spalva
                        foregroundColor: Colors.blue, // Teksto ir ikonos spalva
                      ),
                      child: const Text(
                        'Pridėti užduotį',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Statistika',
                      style: TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
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

  void _showCustomGoalDialog(BuildContext context) {
    TextEditingController titleController =
        TextEditingController(text: widget.goal.goalType.title);
    TextEditingController descriptionController =
        TextEditingController(text: widget.goal.goalType.description);
    GoalTypeService _goalTypeService = GoalTypeService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Redaguoti tikslą"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Pavadinimas",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Aprašymas",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Uždaryti
              },
              child: const Text("Atšaukti"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  widget.goal.goalType.title = titleController.text;
                  widget.goal.goalType.description = descriptionController.text;
                });
                try {
                  await _goalTypeService
                      .updateGoalTypeEntry(widget.goal.goalType);
                  showCustomSnackBar(
                      context, "Tikslas sėkmingai atnaujintas ✅", true);
                } catch (e) {
                  showCustomSnackBar(
                      context, "Klaida atnaujinant tikslą ❌", false);
                }

                Navigator.pop(context); // Uždaryti po išsaugojimo
              },
              child: const Text("Išsaugoti"),
            ),
          ],
        );
      },
    );
  }

  void _showCustomTaskDialog(BuildContext context, GoalTask task) {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    TextEditingController descriptionController =
        TextEditingController(text: task.description);
    GoalTaskService _goalTaskService = GoalTaskService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Redaguoti užduotį"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Pavadinimas",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Aprašymas",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Uždaryti
              },
              child: const Text("Atšaukti"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  task.title = titleController.text;
                  task.description = descriptionController.text;
                });
                try {
                  await _goalTaskService
                      .updateGoalTaskEntry(task); // Atnaujinti užduotį
                  showCustomSnackBar(
                      context, "Tikslo užduotis sėkmingai atnaujintas ✅", true);
                } catch (e) {
                  showCustomSnackBar(
                      context, "Klaida atnaujinant tikslo užduotį ❌", false);
                }

                Navigator.pop(context); // Uždaryti po išsaugojimo
              },
              child: const Text("Išsaugoti"),
            ),
          ],
        );
      },
    );
  }

  // Progreso indikatorius su procentais
  Widget _buildProgressIndicator(double progress) {
    String plantType = widget
        .goal.goalModel.plantId; // Pavyzdžiui, naudotojas pasirenka augalą
    int userPoints = widget.goal.goalModel.points;
    String imagePath = PlantImageService.getPlantImage(plantType, userPoints);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Semantics(
            label: 'Progreso indikatorius', // Apibūdinimas
            value:
                '${(progress * 100).toStringAsFixed(0)}%', // Naudok string su nuliais po kablelio
            child: CircularProgressIndicator(
              value: progress, // Progreso reikšmė (0.0 - 1.0)
              strokeWidth: 10,
              backgroundColor: Colors.grey[100], // Pilkas fonas
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFCDE499)), // Violetinė linija
            ),
          ),
        ),
        CustomPaint(
          size: Size(220, 220),
          painter: PercentagePainter(progress),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 170,
              height: 170,
            ),
          ],
        ),
      ],
    );
  }

  // Tikslų kortelių kūrimo funkcija
  Widget _buildGoalItemTrue(GoalTask task) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF72ddf7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                task.title,
                style: TextStyle(color: Colors.grey[300]),
              ),
              subtitle: Text(
                task.description,
                style: TextStyle(color: Colors.grey[300]),
              ),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  setState(() {
                    task.isCompleted = value ?? false;
                    task.points = _calculatePoints();
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tikslų kortelių kūrimo funkcija
  Widget _buildGoalItemFalse(GoalTask task, int length) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF72ddf7).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(task.title),
              subtitle: Text(task.description),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  setState(() {
                    task.isCompleted = value ?? false;
                    task.points = _calculatePoints();
                  });
                },
                activeColor: Colors.blue,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showCustomTaskDialog(context, task);
              });
            },
            icon: Icon(Icons.edit_outlined, color: Colors.deepPurple),
          ),
          if (length > 1) // Patikriname, ar yra daugiau nei viena užduotis
            IconButton(
              onPressed: () {
                // Rodyti dialogą su klausimu
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text.rich(
                        TextSpan(
                          text:
                              "${task.title}\n", // Pirmoji dalis (pavadinimas)
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.deepPurple), // Pavadinimo stilius
                          children: [
                            TextSpan(
                              text:
                                  "Ar tikrai norite ištrinti šią užduotį?", // Antra dalis
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.normal, // Normalus svoris
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      content:
                          Text("Šios užduoties ištrynimas bus negrįžtamas."),
                      actions: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Centruoja mygtukus
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Uždaro dialogą (Ne pasirinkimas)
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.deepPurple
                                    .withOpacity(0.2), // Neryškus fonas
                              ),
                              child: Text(
                                "Ne",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(width: 20), // Tarpas tarp mygtukų
                            TextButton(
                              onPressed: () {
                                _deleteTask(task.id); // Ištrina įprotį
                                Navigator.pop(context); // Uždarome dialogą
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red
                                    .withOpacity(0.2), // Neryškus fonas
                              ),
                              child: Text(
                                "Taip",
                                style: TextStyle(
                                  color: Colors.red,
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
              },
              icon: Icon(Icons.remove_circle_outline, color: Colors.deepPurple),
            ),
        ],
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
              color: const Color(0xFF72ddf7),
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF72ddf7).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter klase, kuri piešia procentus
class PercentagePainter extends CustomPainter {
  final double progress;

  PercentagePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: Colors.deepPurple,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Kampas pagal progresą (0% = -90° (aukščiausias taškas), 100% = pilnas apskritimas)
    double angle = -pi / 2 + progress * 2 * pi;

    // Apskaičiuojame tekstą ant apskritimo krašto
    double radius = size.width / 2; // Pusė apskritimo skersmens
    double textX = size.width / 2 + radius * cos(angle);
    double textY = size.height / 2 + radius * sin(angle);

    // Šiek tiek patraukiam procentus nuo krašto, kad jie nesiliestų prie linijos
    double textOffset = 10;
    textX += textOffset * cos(angle);
    textY += textOffset * sin(angle);

    // Nubrėžiame procentus
    textPainter.paint(
      canvas,
      Offset(
        textX - textPainter.width / 2, // Centruojame tekstą X ašyje
        textY - textPainter.height / 2, // Centruojame tekstą Y ašyje
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
