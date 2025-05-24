import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';

class HabitProgressChart extends StatelessWidget {
  final HabitModel habit;
  final List<HabitProgress> progressList;

  const HabitProgressChart({
    super.key,
    required this.habit,
    required this.progressList,
  });

  @override
  Widget build(BuildContext context) {
    return _buildChart(progressList, habit);
  }

  Widget _buildChart(List<HabitProgress> progressList, HabitModel habit) {
    final List<FlSpot> realSpots = [];
    final List<FlSpot> idealSpots = [];

    final DateTime startDate = habit.startDate;
    final DateTime endDate = habit.endDate;

    int completedCount = 0;
    int totalDays = endDate.difference(startDate).inDays + 1;

    for (int i = 0; i < totalDays; i++) {
      final currentDate = startDate.add(Duration(days: i));

      final isCompletedToday = progressList.any((p) =>
          p.isCompleted &&
          p.date.year == currentDate.year &&
          p.date.month == currentDate.month &&
          p.date.day == currentDate.day);

      if (isCompletedToday) {
        completedCount++;
        double percent = completedCount / totalDays * 100;
        realSpots.add(FlSpot(i.toDouble(), percent));
      }

      // Vis tiek generuojam idealų tašką kiekvienai dienai
      double idealPercent = ((i + 1) / totalDays) * 100;
      idealSpots.add(FlSpot(i.toDouble(), idealPercent));
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
          minX: 0,
          maxX: totalDays.toDouble() - 1,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
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
                showTitles: false,
                getTitlesWidget: (value, _) {
                  if (value == 0 || value == totalDays - 1) {
                    return Text('${value.toInt() + 1}');
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
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: realSpots,
              isCurved: true,
              color: const Color(0xFFB388EB),
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFB388EB).withOpacity(0.3),
              ),
            ),
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
