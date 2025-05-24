import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';

class SharedGoalProgressChart extends StatelessWidget {
  final SharedGoal goal;
  final List<GoalTask> goalTasksMine;
  final List<GoalTask> goalTasksFriend;

  const SharedGoalProgressChart({
    super.key,
    required this.goal,
    required this.goalTasksMine,
    required this.goalTasksFriend,
  });

  @override
  Widget build(BuildContext context) {
    return _buildChart(goalTasksMine, goalTasksFriend);
  }

  Widget _buildChart(List<GoalTask> tasksMine, List<GoalTask> tasksFriend) {
    final List<FlSpot> mySpots = [];
    final List<FlSpot> friendSpots = [];
    final List<FlSpot> idealSpots = [];

    final totalTasks =
        tasksMine.length; // Naudojame jūsų užduočių skaičių kaip bazę
    int myCompletedCount = 0;
    int friendCompletedCount = 0;

    // Generuojame idealią liniją
    for (int i = 0; i < totalTasks; i++) {
      final idealPercent = ((i + 1) / totalTasks) * 100;
      idealSpots.add(FlSpot((i + 1).toDouble(), idealPercent));
    }

    // Skaičiuojame jūsų progresą
    int myTaskIndex = 0;
    for (var task in tasksMine) {
      if (task.isCompleted) {
        myCompletedCount++;
        final percent = myCompletedCount / totalTasks * 100;
        mySpots.add(FlSpot((myTaskIndex + 1).toDouble(), percent));
        myTaskIndex++;
      }
    }

    // Skaičiuojame draugo progresą
    int friendTaskIndex = 0;
    for (var task in tasksFriend) {
      if (task.isCompleted) {
        friendCompletedCount++;
        final percent = friendCompletedCount / totalTasks * 100;
        friendSpots.add(FlSpot((friendTaskIndex + 1).toDouble(), percent));
        friendTaskIndex++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          minX: 1,
          maxX: totalTasks.toDouble(),
          gridData: FlGridData(show: true), // Be tinklelio linijų
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(),
              bottom: BorderSide(),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          lineBarsData: [
            // Jūsų progresas (žalia spalva)
            LineChartBarData(
              spots: mySpots,
              isCurved: true,
              color: Colors.lightGreen.shade700, // Žalia spalva
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.lightGreen.shade700.withOpacity(0.3),
              ),
              barWidth: 2,
            ),
            // Draugo progresas (mėlyna spalva)
            LineChartBarData(
              spots: friendSpots,
              isCurved: true,
              color: Colors.deepPurple.shade300, // Mėlyna spalva
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepPurple.shade300.withOpacity(0.3),
              ),
              barWidth: 2,
            ),
            // Ideali linija
            LineChartBarData(
              spots: idealSpots,
              isCurved: false,
              color: Colors.pinkAccent,
              dotData: FlDotData(show: false),
              isStrokeCapRound: true,
              barWidth: 1,
              dashArray: [3, 5],
            ),
          ],
        ),
      ),
    );
  }
}
