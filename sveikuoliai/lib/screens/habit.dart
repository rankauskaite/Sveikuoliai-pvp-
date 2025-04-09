import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habits_goals.dart';
import 'package:sveikuoliai/services/habit_progress_services.dart';
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/habit_type_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/services/plant_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

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
  HabitProgress habitProgress = HabitProgress(
      id: '',
      habitId: '',
      description: '',
      points: 0,
      plantUrl: '',
      date: DateTime.now(),
      isCompleted: false);
  final TextEditingController _progressController = TextEditingController();
  String? _currentProgressId; // Saugo esamo progreso ID, jei jis egzistuoja
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
      HabitProgress? fetchedHabitProgress = await _habitProgressService
          .getLatestHabitProgress(widget.habit.habitModel.id);

      if (fetchedHabitProgress != null) {
        setState(() {
          habitProgress = fetchedHabitProgress;
        });
      } else {
        //throw Exception("Gautas `null` įpročio progreso objektas");
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
        _currentProgressId = progress.id; // Išsaugome ID atnaujinimui
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
                                          "${widget.habit.habitType.title}\n", // Pirmoji dalis (pavadinimas)
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors
                                              .deepPurple), // Pavadinimo stilius
                                      children: [
                                        TextSpan(
                                          text:
                                              "Ar tikrai norite ištrinti šį įprotį?", // Antra dalis
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
                                      "Šio įpročio ištrynimas bus negrįžtamas."),
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
                                            _deleteHabit(); // Ištrina įprotį
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
                      widget.habit.habitType.title,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB388EB),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progreso indikatorius su procentais
                    _buildProgressIndicator(
                        _calculateProgress()), // Pvz., 60% progresas

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showProgressDialog(context);
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
        TextEditingController(text: widget.habit.habitType.title);
    TextEditingController descriptionController =
        TextEditingController(text: widget.habit.habitType.description);
    HabitTypeService _habitTypeService = HabitTypeService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Redaguoti įprotį"),
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
                  widget.habit.habitType.title = titleController.text;
                  widget.habit.habitType.description =
                      descriptionController.text;
                });
                try {
                  await _habitTypeService
                      .updateHabitTypeEntry(widget.habit.habitType);
                  showCustomSnackBar(
                      context, "Įprotis sėkmingai atnaujintas ✅", true);
                } catch (e) {
                  showCustomSnackBar(
                      context, "Klaida atnaujinant įprotį ❌", false);
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

  void _showProgressDialog(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atnaujink savo progresą',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                widget.habit.habitType.title,
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB388EB)),
              ),
              const SizedBox(height: 10),
              Text(
                'Data: $formattedDate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _progressController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Įveskite informaciją',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Uždaro dialogą
              },
              child: Text('Atšaukti'),
            ),
            ElevatedButton(
              onPressed: () async {
                final habitProgressService = HabitProgressService();
                final habitService = HabitService();

                HabitProgress newProgress = HabitProgress(
                  id: _currentProgressId ??
                      '${widget.habit.habitModel.habitTypeId}${widget.habit.habitModel.userId[0].toUpperCase() + widget.habit.habitModel.userId.substring(1)}${DateTime.now()}',
                  habitId: widget.habit.habitModel.id,
                  description: _progressController.text,
                  points: _currentProgressId != null ? pointss : ++pointss,
                  streak: _currentProgressId != null ? streakk : ++streakk,
                  plantUrl: PlantImageService.getPlantImage(
                      widget.habit.habitModel.plantId,
                      widget.habit.habitModel.points + 1),
                  date: DateTime.now(),
                  isCompleted: true,
                );

                await habitProgressService
                    .createHabitProgressEntry(newProgress);

                HabitModel updatedHabit = HabitModel(
                  id: widget.habit.habitModel.id,
                  startDate: widget.habit.habitModel.startDate,
                  endDate: widget.habit.habitModel.endDate,
                  points: newProgress.points,
                  category: widget.habit.habitModel.category,
                  endPoints: widget.habit.habitModel.endPoints,
                  repetition: widget.habit.habitModel.repetition,
                  userId: widget.habit.habitModel.userId,
                  habitTypeId: widget.habit.habitModel.habitTypeId,
                  plantId: widget.habit.habitModel.plantId,
                );

                await habitService.updateHabitEntry(updatedHabit);

                if (context.mounted) {
                  showCustomSnackBar(context, 'Progresas išsaugotas! 🎉', true);
                  Navigator.pop(context); // Uždaro dialogą
                }
              },
              child: Text('Išsaugoti'),
            ),
          ],
        );
      },
    );
  }

  // Progreso indikatorius su procentais
  Widget _buildProgressIndicator(double progress) {
    String plantType = widget
        .habit.habitModel.plantId; // Pavyzdžiui, naudotojas pasirenka augalą
    int userPoints = habitProgress.points;
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
