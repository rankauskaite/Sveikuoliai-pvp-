import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';

// Progreso indikatorius su procentais
Widget buildProgressIndicator(double progress, String plantId, int points,
    bool isPlantDead, bool isDarkMode) {
  String plantType = plantId;
  int userPoints = points;
  String imagePath = "";
  // Patikrina ar data yra užvakar arba senesnė
  if (isPlantDead) {
    imagePath = HighDeadPlantImageService.getPlantImage(plantType, userPoints);
  } else {
    imagePath = HighPlantImageService.getPlantImage(plantType, userPoints);
  }

  //PlantImageService.getPlantImage(plantType, userPoints);
  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: 220,
        height: 220,
        child: Semantics(
          label: 'Progreso indikatorius',
          value: '${(progress * 100).toStringAsFixed(0)}%',
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: isDarkMode ? Colors.grey[400] : Colors.grey[100],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCDE499)),
          ),
        ),
      ),
      CustomPaint(
        size: Size(220, 220),
        painter: PercentagePainter(progress, isDarkMode),
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

// CustomPainter klase, kuri piešia procentus
class PercentagePainter extends CustomPainter {
  final double progress;
  final bool isDarkMode;

  PercentagePainter(this.progress, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double angle = -pi / 2 + progress * 2 * pi;
    double radius = size.width / 2;
    double textX = size.width / 2 + radius * cos(angle);
    double textY = size.height / 2 + radius * sin(angle);

    double textOffset = 10;
    textX += textOffset * cos(angle);
    textY += textOffset * sin(angle);

    textPainter.paint(
      canvas,
      Offset(
        textX - textPainter.width / 2,
        textY - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
