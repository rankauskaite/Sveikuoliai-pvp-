import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';
import 'package:sveikuoliai/models/goal_progress_model.dart';

class GoalProgressChart extends StatelessWidget {
  final GoalModel goal;
  final List<GoalTask> goalTasks;

  const GoalProgressChart({
    super.key,
    required this.goal,
    required this.goalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return _buildChart(goalTasks);
  }

  Widget _buildChart(List<GoalTask> tasks) {
  final List<FlSpot> realSpots = [];
  final List<FlSpot> idealSpots = [];

  final totalTasks = tasks.length;
  int completedCount = 0;

  for (int i = 0; i < totalTasks; i++) {
    final idealPercent = ((i + 1) / totalTasks) * 100;
    idealSpots.add(FlSpot((i + 1).toDouble(), idealPercent));
  }

  for (var task in tasks) {
  if (task.isCompleted) {
    completedCount++;
    final percent = completedCount / totalTasks * 100;
    realSpots.add(FlSpot(completedCount.toDouble(), percent));
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
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, _) {
                if (value % 20 == 0) {
                  return Text('${value.toInt()}%');
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value == 1 || value == totalTasks) {
                  return Text('${value.toInt()}');
                }
                return const SizedBox.shrink();
              },
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
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: realSpots,
            isCurved: true,
            color: const Color(0xFF72ddf7),
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF72ddf7).withOpacity(0.2),
            ),
          ),
          LineChartBarData(
            spots: idealSpots,
            isCurved: false,
            color: Colors.pinkAccent,
            dotData: FlDotData(show: false),
            barWidth: 2,
            dashArray: [4, 2],
          ),
        ],
      ),
    ),
  );
}


  
}
