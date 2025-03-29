import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show DateFormat;
//import 'package:intl/intl.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/plant_model.dart';
import 'package:sveikuoliai/screens/habit_progress.dart';
import 'package:sveikuoliai/screens/update_habit_goal.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchPlantData();
  }

  // Funkcija, kad gauti prisijungusio vartotojo duomenis
  Future<void> _fetchPlantData() async {
    try {
      PlantModel? fetchedPlant =
          await _plantService.getPlantEntry(widget.habit.plantId);
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
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UpdateHabitScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
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
                    _buildProgressIndicator(0.7), // Pvz., 60% progresas

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const HabitProgressScreen()),
                        );
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
                          "0",
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
                          widget.habit.endPoints == 7
                              ? "1 savaitė"
                              : widget.habit.endPoints == 14
                                  ? "2 savaitės"
                                  : widget.habit.endPoints == 30
                                      ? "1 mėnuo"
                                      : widget.habit.endPoints == 45
                                          ? "1,5 mėnesio"
                                          : widget.habit.endPoints == 60
                                              ? "2 mėnesiai"
                                              : widget.habit.endPoints == 90
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
                              .format(widget.habit.startDate),
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
                              .format(widget.habit.endDate),
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

  // Progreso indikatorius su procentais
  Widget _buildProgressIndicator(double progress) {
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
              'assets/images/${widget.habit.plantId}/2.png',
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
    final Paint paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

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
