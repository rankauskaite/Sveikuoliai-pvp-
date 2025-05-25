import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';

class SharedGoalProgressChart extends StatelessWidget {
  final SharedGoal sharedGoal;
  final List<GoalTask> goalTasks;

  const SharedGoalProgressChart({
    Key? key,
    required this.sharedGoal,
    required this.goalTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];

    int completed = 0;
    for (int i = 0; i < goalTasks.length; i++) {
      if (goalTasks[i].isCompleted) completed++;
      double progress = (completed / goalTasks.length) * 100;
      spots.add(FlSpot((i + 1).toDouble(), progress));
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
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, _) =>
                    Text('${value.toInt()}%', style: TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) =>
                    Text('${value.toInt()}', style: TextStyle(fontSize: 10)),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFbcd979),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFbcd979).withOpacity(0.2),
              ),
              dotData: FlDotData(show: true),
            ),
            // Idealaus progreso linija y = x
            LineChartBarData(
              spots: List.generate(goalTasks.length, (i) {
                double targetProgress =
                    ((i + 1) / goalTasks.length.toDouble()) * 100;
                return FlSpot((i + 1).toDouble(), targetProgress);
              }),
              isCurved: false,
              color: Colors.pinkAccent.withOpacity(0.5),
              dashArray: [4, 4],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
