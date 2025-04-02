import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  _GardenScreenState createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  final Random _random = Random();
  final int plantCount = 5; // Nustatomas augaliukų skaičius

  List<Positioned> _generatePlants() {
    List<Positioned> plants = [];
    for (int i = 0; i < plantCount; i++) {
      double left = -5 + _random.nextDouble() * 200; // X koordinatė
      double top = 15 + _random.nextDouble() * 20; // Y koordinatė
      plants.add(
        Positioned(
          left: left,
          top: top,
          child: Image.asset(
            'assets/images/saulegraza/12.png',
            width: 100,
            height: 100,
          ),
        ),
      );
    }
    return plants;
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
      body: Stack(
        children: [
          Center(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios, size: 30),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sodas',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Stack(
                        children: [
                          Image.asset(
                            'assets/island3.jpg',
                            width: 300,
                            height: 220,
                          ),
                          ..._generatePlants(),
                        ],
                      ),
                    ],
                  ),
                ),
                const BottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
