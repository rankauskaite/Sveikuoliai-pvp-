import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sveikuoliai/screens/habit_progress.dart';
import 'package:sveikuoliai/screens/update_habit_goal.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalScreen> {
  bool isGoal1Completed = false;
  bool isGoal2Completed = false;
  bool isGoal3Completed = false;

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
                                      const UpdateGoalScreen()),
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
                    const Text(
                      'Tikslo pavadinimas',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF72ddf7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProgressIndicator(0.3),
                    const SizedBox(height: 20),
                    const Text(
                      'Apie tikslą',
                      style: TextStyle(fontSize: 25, color: Color(0xFF72ddf7)),
                    ),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Detalesnė informacija apie tikslą,\nkoks jis yra: aprašymas',
                            style: TextStyle(fontSize: 18),
                          ),
                        ]),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Trukmė: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '2 mėnesiai',
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
                        _buildGoalItem(
                            'Tikslas 1: Pirmas tikslas',
                            'Aprašymas: Šis tikslas apima sveikos mitybos pradėjimą.',
                            isGoal1Completed, (bool? value) {
                          setState(() {
                            isGoal1Completed = value!;
                          });
                        }),
                        _buildGoalItem(
                            'Tikslas 2: Kitas tikslas',
                            'Aprašymas: Tai tikslas, susijęs su fiziniu aktyvumu.',
                            isGoal2Completed, (bool? value) {
                          setState(() {
                            isGoal2Completed = value!;
                          });
                        }),
                        _buildGoalItem(
                            'Tikslas 3: Dar vienas tikslas',
                            'Aprašymas: Įgyvendinti gerą miego režimą.',
                            isGoal3Completed, (bool? value) {
                          setState(() {
                            isGoal3Completed = value!;
                          });
                        }),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HabitProgressScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        iconColor: const Color(0xFF72ddf7), // Violetinė spalva
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

  // Progreso indikatorius su procentais
  Widget _buildProgressIndicator(double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.local_florist,
              size: 170,
              color: Color(0xFF72ddf7),
            ),
          ],
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 20,
          height: 200,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 20,
                color: Colors.grey[100],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 20,
                  height: 200 * progress,
                  color: const Color(0xFFCDE499),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  // Tikslų kortelių kūrimo funkcija
  Widget _buildGoalItem(String title, String subtitle, bool value,
      ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF72ddf7).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
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
