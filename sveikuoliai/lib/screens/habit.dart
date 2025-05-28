import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/auth_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_dialogs.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';
import 'package:sveikuoliai/widgets/habit_progress_graph.dart';
import 'package:sveikuoliai/widgets/progress_indicator.dart';

class HabitScreen extends StatefulWidget {
  final HabitInformation habit;
  const HabitScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  PlantModel plant = PlantModel(
    id: '',
    name: '',
    points: 0,
    photoUrl: '',
    duration: 0,
  );
  final HabitService _habitService = HabitService();
  final AuthService _authService = AuthService(); // Pridėtas AuthService
  bool notifications = true;
  bool isDarkMode = false; // Temos būsena
  List<HabitProgress> progressList = [];
  HabitProgress? habitProgress; // Pakeista į nullable tipą
  final TextEditingController _progressController = TextEditingController();
  int pointss = 0;
  int streakk = 0;
  late DateTime lastProgressDate;

  @override
  void initState() {
    super.initState();
    lastProgressDate = widget.habit.habitModel.startDate;
    _loadData();
  }

  // Funkcija duomenims užkrauti
  Future<void> _loadData() async {
    await _fetchUserData(); // Pridėta sesijos duomenų gavimas
    await _fetchPlantData();
    await _fetchHabitProgress();
    _loadProgress();
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
        (p) => p.id == widget.habit.habitModel.plantId,
      );
      setState(() {
        plant = fetchedPlant;
      });
    } catch (e) {
      String message = 'Klaida gaunant augalo duomenis ❌';
      showCustomSnackBar(context, message, false);
    }
  }

  Future<void> _fetchHabitProgress() async {
    try {
      Map<String, List<HabitProgress>> allProgress =
          await _authService.getHabitProgressFromSession();
      String habitId = widget.habit.habitModel.id;

      if (allProgress.isNotEmpty && allProgress.containsKey(habitId)) {
        List<HabitProgress> habitProgressList = allProgress[habitId]!;
        setState(() {
          progressList = habitProgressList;
          habitProgress =
              habitProgressList.isNotEmpty ? habitProgressList.last : null;
          lastProgressDate =
              habitProgress?.date ?? widget.habit.habitModel.startDate;
        });

        if (habitProgress != null && !widget.habit.habitModel.isCompleted) {
          bool isDead = isPlantDead(lastProgressDate);
          if (widget.habit.habitModel.isPlantDead != isDead) {
            setState(() {
              widget.habit.habitModel.isPlantDead = isDead;
            });
            await _habitService.updateHabitEntry(widget.habit.habitModel);
            // Atnaujiname sesiją su naujausiais duomenimis
            List<HabitInformation> habits =
                await _authService.getHabitsFromSession();
            int habitIndex = habits.indexWhere(
                (g) => g.habitModel.id == widget.habit.habitModel.id);
            if (habitIndex != -1) {
              habits[habitIndex] = widget.habit; // Atnaujiname esamą tikslą
            } else {
              habits.add(widget.habit); // Jei tikslo dar nėra, pridedame
            }
            await _authService.saveHabitsToSession(habits);
          }
        }
      } else {
        setState(() {
          progressList = [];
          habitProgress = null;
          lastProgressDate = widget.habit.habitModel.startDate;
        });
      }
    } catch (e) {
      showCustomSnackBar(context, 'Klaida kraunant įpročio progresą ❌', false);
      setState(() {
        progressList = [];
        habitProgress = null;
        lastProgressDate = widget.habit.habitModel.startDate;
      });
      print('Klaida _fetchHabitProgress: $e');
    }
  }

  bool isPlantDead(DateTime date) {
    DateTime today = DateTime.now();
    DateTime twoDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 2));
    DateTime threeDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 3));
    DateTime weekAgo = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 7));
    if (widget.habit.habitModel.plantId == "dobiliukas" &&
        date.isBefore(twoDaysAgo)) {
      showCustomPlantSnackBar(
        context,
        "${getPlantName(widget.habit.habitModel.plantId)} bent 2 dienas 🥺",
      );

      return true;
    } else if (widget.habit.habitModel.plantId == "ramuneles" ||
        widget.habit.habitModel.plantId == "zibuokle" ||
        widget.habit.habitModel.plantId == "saulegraza") {
      if (date.isBefore(threeDaysAgo)) {
        showCustomPlantSnackBar(
          context,
          "${getPlantName(widget.habit.habitModel.plantId)} bent 3 dienas 🥺",
        );

        return true;
      }
    } else if (widget.habit.habitModel.plantId == "orchideja" ||
        widget.habit.habitModel.plantId == "gervuoge" ||
        widget.habit.habitModel.plantId == "vysnia") {
      if (date.isBefore(weekAgo)) {
        showCustomPlantSnackBar(
          context,
          "${getPlantName(widget.habit.habitModel.plantId)} bent savaitę 🥺",
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
      backgroundColor: Colors.purple.shade400.withOpacity(0.6),
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

  double _calculateProgress() {
    if (widget.habit.habitModel.endPoints == 0)
      return 0.0; // Apsauga nuo dalybos iš nulio
    return widget.habit.habitModel.points / widget.habit.habitModel.endPoints;
  }

  Future<void> _deleteHabit() async {
    try {
      await _habitService.deleteHabitEntry(widget.habit.habitModel.id);
      await _authService.removeHabitFromSession(widget.habit);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HabitsGoalsScreen(selectedIndex: 0)),
      );
      showCustomSnackBar(context, "Įprotis sėkmingai ištrintas ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant įprotį ❌", false);
    }
  }

  void _loadProgress() {
    // Filtruojame progreso įrašus pagal dabartinę dieną
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    HabitProgress? todayProgress = progressList
            .where(
              (progress) =>
                  DateTime(progress.date.year, progress.date.month,
                      progress.date.day) ==
                  todayDate,
            )
            .isNotEmpty
        ? progressList.firstWhere(
            (progress) =>
                DateTime(progress.date.year, progress.date.month,
                    progress.date.day) ==
                todayDate,
          )
        : null;

    // Gauname paskutinį progreso įrašą
    HabitProgress? lastProgress =
        progressList.isNotEmpty ? progressList.last : null;

    if (todayProgress != null) {
      setState(() {
        _progressController.text = todayProgress.description;
        pointss = lastProgress?.points ?? 0;
        streakk = lastProgress?.streak ?? 0;
      });
    } else if (lastProgress != null) {
      setState(() {
        pointss = lastProgress.points;
        if (lastProgress.date.day == DateTime.now().day - 1) {
          streakk = lastProgress.streak;
        } else {
          streakk = 0; // Reset streak, jei nėra progreso vakar
        }
      });
    } else {
      setState(() {
        pointss = 0;
        streakk = 0;
      });
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
            const SizedBox(height: topPadding),
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
                                        HabitsGoalsScreen(selectedIndex: 0)),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          if (widget.habit.habitType.type == 'custom' &&
                              widget.habit.habitModel.isCompleted == false)
                            IconButton(
                              onPressed: () {
                                CustomDialogs.showEditDialog(
                                  context: context,
                                  entityType: EntityType.habit,
                                  entity: widget.habit,
                                  accentColor: isDarkMode
                                      ? Colors.purple[300]!
                                      : Color(0xFFB388EB),
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
                                entityType: EntityType.habit,
                                entity: widget.habit,
                                accentColor: isDarkMode
                                    ? Colors.purple[300]!
                                    : Color(0xFFB388EB),
                                onDelete: () {
                                  _deleteHabit();
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
                        widget.habit.habitType.title,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.purple[300]
                              : Color(0xFFB388EB),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildProgressIndicator(
                        _calculateProgress(),
                        widget.habit.habitModel.plantId,
                        widget.habit.habitModel.points,
                        widget.habit.habitModel.isPlantDead,
                        isDarkMode,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: widget.habit.habitModel.isCompleted
                            ? null
                            : () {
                                CustomDialogs.showProgressDialog(
                                  context: context,
                                  habit: widget.habit,
                                  accentColor: isDarkMode
                                      ? Colors.purple[300]!
                                      : Color(0xFFB388EB),
                                  onSave: () async {},
                                  progressController: _progressController,
                                  points: pointss,
                                  streak: streakk,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: widget.habit.habitModel.isCompleted
                              ? (isDarkMode ? Colors.grey[700] : Colors.grey)
                              : (isDarkMode ? Colors.white : null),
                          foregroundColor: isDarkMode
                              ? Colors.black
                              : const Color(0xFFB388EB),
                        ),
                        child: Text(
                          widget.habit.habitModel.isCompleted
                              ? 'Įprotis baigtas'
                              : 'Žymėti progresą',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode
                                ? (widget.habit.habitModel.isCompleted
                                    ? Colors.white70
                                    : Colors.deepPurple)
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Streak: ',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDarkMode
                                  ? Colors.purple[300]
                                  : Color(0xFFB388EB),
                            ),
                          ),
                          Text(
                            habitProgress != null &&
                                    (habitProgress!.date.day ==
                                            DateTime.now().day ||
                                        habitProgress!.date.day ==
                                            DateTime.now().day - 1)
                                ? habitProgress!.streak.toString()
                                : "0",
                            style: TextStyle(
                              fontSize: 15,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Color(0xFF8093F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Apie įprotį',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.purple[300]
                              : Color(0xFFB388EB),
                        ),
                      ),
                      Text(
                        widget.habit.habitType.description,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
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
                            widget.habit.habitModel.endPoints == 7
                                ? "1 savaitė"
                                : widget.habit.habitModel.endPoints == 14
                                    ? "2 savaitės"
                                    : widget.habit.habitModel.endPoints == 30
                                        ? "1 mėnuo"
                                        : widget.habit.habitModel.endPoints ==
                                                45
                                            ? "1,5 mėnesio"
                                            : widget.habit.habitModel
                                                        .endPoints ==
                                                    60
                                                ? "2 mėnesiai"
                                                : widget.habit.habitModel
                                                            .endPoints ==
                                                        90
                                                    ? "3 mėnesiai"
                                                    : "6 mėnesiai",
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.purple[300]
                                  : Color(0xFFB388EB),
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
                                .format(widget.habit.habitModel.startDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.purple[300]
                                  : Color(0xFFB388EB),
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
                                .format(widget.habit.habitModel.endDate),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.purple[300]
                                  : Color(0xFFB388EB),
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
                                  ? Colors.purple[300]
                                  : Color(0xFFB388EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Statistika',
                        style: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.purple[300]
                              : Color(0xFFB388EB),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: progressList.isEmpty
                            ? Text(
                                "Nėra progreso duomenų",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.grey[600]
                                      : Colors.grey,
                                ),
                              )
                            : HabitProgressChart(
                                habit: widget.habit.habitModel,
                                progressList: progressList,
                              ),
                      ),
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
}
