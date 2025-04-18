import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/habit_progress_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
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
      id: '', name: '', points: 0, photoUrl: '', duration: 0, stages: []);
  final PlantService _plantService = PlantService();
  final HabitProgressService _habitProgressService = HabitProgressService();
  List<HabitProgress> progressList = [];
  HabitProgress habitProgress = HabitProgress(
      id: '',
      habitId: '',
      description: '',
      points: 0,
      plantUrl: '',
      date: DateTime.now(),
      isCompleted: false);
  final TextEditingController _progressController = TextEditingController();
  int pointss = 0;
  int streakk = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Funkcija duomenims užkrauti
  Future<void> _loadData() async {
    await _fetchPlantData();
    await _fetchHabitProgress();
    _loadProgress();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchPlantData() async {
    try {
      PlantModel? fetchedPlant =
          await _plantService.getPlantEntry(widget.habit.habitModel.plantId);
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

  Future<void> _fetchHabitProgress() async {
  try {
    List<HabitProgress> all = await _habitProgressService.getAllHabitProgress(widget.habit.habitModel.id);

    if (all.isNotEmpty) {
      setState(() {
        progressList = all;
        habitProgress = all.last;
      });
    }
  } catch (e) {
    showCustomSnackBar(context, 'Klaida kraunant įpročio progresą ❌', false);
  }
}


  double _calculateProgress() {
    if (widget.habit.habitModel.endPoints == 0)
      return 0.0; // Apsauga nuo dalybos iš nulio
    return habitProgress.points / widget.habit.habitModel.endPoints;
  }

  Future<void> _deleteHabit() async {
    try {
      final habitService = HabitService();
      await habitService.deleteHabitEntry(
          widget.habit.habitModel.id); // Ištrinti įprotį iš serverio
      // Gali prireikti papildomų veiksmų, pvz., navigacija į kitą ekraną po ištrynimo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HabitsGoalsScreen()),
      ); // Grįžti atgal į pagrindinį ekraną
      showCustomSnackBar(context, "Įprotis sėkmingai ištrintas ✅", true);
    } catch (e) {
      showCustomSnackBar(context, "Klaida trinant įprotį ❌", false);
    }
  }

  void _loadProgress() async {
    final habitProgressService = HabitProgressService();
    HabitProgress? progress = await habitProgressService
        .getTodayHabitProgress(widget.habit.habitModel.id);
    HabitProgress? lastProgress = await habitProgressService
        .getLatestHabitProgress(widget.habit.habitModel.id);

    if (progress != null) {
      setState(() {
        _progressController.text = progress.description;
// Išsaugome ID atnaujinimui
        pointss = lastProgress!.points;
        streakk = lastProgress.streak;
      });
    } else if (lastProgress != null) {
      setState(
        () {
          pointss = lastProgress.points;
          if (lastProgress.date.day == DateTime.now().day - 1) {
            streakk = lastProgress.streak;
          }
        },
      );
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
                        if (widget.habit.habitType.type == 'custom')
                          IconButton(
                            onPressed: () {
                              CustomDialogs.showEditDialog(
                                  context: context,
                                  entityType: EntityType.habit,
                                  entity: widget.habit,
                                  accentColor: Color(0xFFB388EB),
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
                              entityType: EntityType.habit,
                              entity: widget.habit,
                              accentColor: Color(0xFFB388EB),
                              onDelete: () {
                                _deleteHabit();
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
                      widget.habit.habitType.title,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB388EB),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progreso indikatorius su procentais
                    buildProgressIndicator(
                      _calculateProgress(),
                      widget.habit.habitModel.plantId,
                      widget.habit.habitModel.points,
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        CustomDialogs.showProgressDialog(
                            context: context,
                            habit: widget.habit,
                            accentColor: Color(0xFFB388EB),
                            onSave: () {},
                            progressController: _progressController,
                            points: pointss,
                            streak: streakk);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        iconColor: const Color(0xFFB388EB), // Violetinė spalva
                      ),
                      child: const Text(
                        'Žymėti progresą',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Streak: ',
                          style:
                              TextStyle(fontSize: 15, color: Color(0xFFB388EB)),
                        ),
                        Text(
                          (habitProgress.date.day == DateTime.now().day ||
                                  habitProgress.date.day ==
                                      DateTime.now().day - 1)
                              ? habitProgress.streak.toString()
                              : "0",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8093F1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Apie įprotį',
                      style: TextStyle(fontSize: 25, color: Color(0xFFB388EB)),
                    ),
                    Text(
                      widget.habit.habitType.description,
                      style: const TextStyle(fontSize: 18),
                      softWrap: true, // Leisti tekstui kelti į kitą eilutę
                      overflow: TextOverflow.visible, // Nesutrumpinti teksto
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Trukmė: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          widget.habit.habitModel.endPoints == 7
                              ? "1 savaitė"
                              : widget.habit.habitModel.endPoints == 14
                                  ? "2 savaitės"
                                  : widget.habit.habitModel.endPoints == 30
                                      ? "1 mėnuo"
                                      : widget.habit.habitModel.endPoints == 45
                                          ? "1,5 mėnesio"
                                          : widget.habit.habitModel.endPoints ==
                                                  60
                                              ? "2 mėnesiai"
                                              : widget.habit.habitModel
                                                          .endPoints ==
                                                      90
                                                  ? "3 mėnesiai"
                                                  : "6 mėnesiai",
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFB388EB)),
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
                              .format(widget.habit.habitModel.startDate),
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFB388EB)),
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
                              .format(widget.habit.habitModel.endDate),
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFB388EB)),
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
                              TextStyle(fontSize: 18, color: Color(0xFFB388EB)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Statistika',
                      style: TextStyle(fontSize: 25, color: Color(0xFFB388EB)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: progressList.isEmpty
                          ? const Text("Nėra progreso duomenų")
                          : HabitProgressChart(
                              habit: widget.habit.habitModel,
                              progressList: progressList,
                            ),

                    ),
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
      padding: const EdgeInsets.all(10), // Tarpo aplink grafiką
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0), // Šviesiai pilkas fonas
        borderRadius: BorderRadius.circular(15), // Užapvalinti kampai
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
              color: const Color(0xFFB388EB), // Violetinė linija
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFB388EB)
                    .withOpacity(0.2), // Pusiau permatomas fonas po linija
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
