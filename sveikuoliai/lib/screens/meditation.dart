import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  late RiveAnimationController _riveController;
  bool _isBreathing = false;
  bool _isAnimationRunning =
      false; // Naujas kintamasis, kad sekame animacijos būseną
  int _breathStage = 0; // 0 = Inhale, 1 = Hold, 2 = Exhale
  int _elapsedTime = 0;
  int _counts = 0; // Kiek kartų atlikta ciklą

  // Kvėpavimo etapo trukmės
  final int inhaleDuration = 3; // Įkvėpimas
  final int holdDuration = 3; // Sulaikymas
  final int exhaleDuration = 4; // Iškvepimas
  int totalCycleRepetiton = 2; // Bendras ciklo kartojimo skaičius

  String _breathingText = ""; // Kvėpavimo tekstas
  String _timerText = ""; // Atbulinio laikymo tekstas
  // Removed this line as it is misplaced and causes errors

  @override
  void initState() {
    super.initState();
    _riveController = SimpleAnimation('Timeline 1', autoplay: false);
    _riveController.isActive = false; // Animacija pradžioje neaktyvi
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _counts = 0; // Nustatome ciklus į 0
      _breathStage = 0; // Pradėdami nuo įkvėpimo
      _breathingText = "Įkvėpiama"; // Pradinis tekstas
      _timerText =
          inhaleDuration.toString(); // Užrašykite laiką nuo pirmos sekundės
      _isAnimationRunning = true; // Animacija prasideda
    });

    _riveController.isActive = true; // Activate the Rive animation controller

    // Timer'is valdo kvėpavimo etapus
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isAnimationRunning || !mounted) {
        timer.cancel(); // Cancel the timer if the widget is no longer mounted
        return; // Prevent any further updates
      }

      setState(() {
        _elapsedTime++; // Didiname laiką
      });

      if (_breathStage == 0) {
        // Įkvėpimas
        if (_elapsedTime <= inhaleDuration) {
          setState(() {
            _breathingText = "Įkvėpiama";
            _timerText =
                (inhaleDuration - _elapsedTime).toString(); // Atbulinis laikas
          });
        } else {
          setState(() {
            _breathStage = 1; // Pereiname į sulaikymą
            _elapsedTime = 0; // Resetuoja laiką
            _breathingText = "Sulaikyk";
            _timerText =
                holdDuration.toString(); // Atbulinis laikas sulaikymo etapui
          });
        }
      } else if (_breathStage == 1) {
        // Sulaikymas
        if (_elapsedTime <= holdDuration) {
          setState(() {
            _breathingText = "Sulaikyk";
            _timerText =
                (holdDuration - _elapsedTime).toString(); // Atbulinis laikas
          });
        } else {
          setState(() {
            _breathStage = 2; // Pereiname į iškvėpimą
            _elapsedTime = 0; // Resetuoja laiką
            _breathingText = "Iškvepiama";
            _timerText =
                exhaleDuration.toString(); // Atbulinis laikas iškvėpimo etapui
          });
        }
      } else if (_breathStage == 2) {
        // Iškvepimas
        if (_elapsedTime <= exhaleDuration) {
          setState(() {
            _breathingText = "Iškvepiama";
            _timerText =
                (exhaleDuration - _elapsedTime).toString(); // Atbulinis laikas
          });
        } else {
          setState(() {
            _breathStage = 0; // Grįžtame prie įkvėpimo
            _elapsedTime = 0;
            _counts++; // Padidiname atliktų ciklų skaičių
            _timerText =
                inhaleDuration.toString(); // Atbulinis laikas įkvėpimo etapui
          });

          if (_counts >= totalCycleRepetiton) {
            setState(() {
              _isBreathing = false;
              _breathingText = "Meditacija baigta";
              _isAnimationRunning = false; // Animacija sustoja
            });
            _riveController.isActive =
                false; // Deactivate the animation when done
            timer.cancel();
          }
        }
      }
    });
  }

  // Funkcija, kuri sugeneruoja patarimo kortelę
  Widget _buildAdviceCard(String adviceText) {
    return Container(
      margin: EdgeInsets.only(bottom: 10), // Tarpai tarp kortelių
      padding: EdgeInsets.all(15), // Padidintas užpildymas
      decoration: BoxDecoration(
        color: Colors.pink.shade50, // Fono spalva
        borderRadius: BorderRadius.circular(10), // Užapvalinti kampai
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        adviceText,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  void _showStressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Patiri stresą ar pyktį?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Šie patarimai tau gali padėti:'),
              SizedBox(height: 10),
              _buildAdviceCard(
                  '1. Pasirink didelį, dviženklį ar net triženkli skaičių ir skaičiuok atbulomis.'),
              _buildAdviceCard('2. Giliai įkvėpk ir iškvėpk kelis kartus.'),
              _buildAdviceCard(
                  '3. Skirk laiko meditacijai arba pasivaikščiojimui.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Uždaryti dialogą
              },
              child: Text('Uždaryti'),
            ),
          ],
        );
      },
    );
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
                          _showStressDialog(
                              context); // Užkrovimas pop-out lango
                        },
                        icon: Icon(
                          Icons.add_alert, // Galite pasirinkti kitą ikoną
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Meditacija',
                    style: TextStyle(fontSize: 35),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 250,
                    height: 250,
                    child: Center(
                      child: RiveAnimation.asset(
                        'assets/rive/meditacija.riv',
                        controllers: [_riveController],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isBreathing) ...[
                    Text(
                      'Kiek kartų noretum kvepuoti?',
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (totalCycleRepetiton > 1) {
                                totalCycleRepetiton--;
                              }
                            });
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text(
                          '$totalCycleRepetiton',
                          style: TextStyle(fontSize: 30),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              totalCycleRepetiton++;
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                  if (_isBreathing) ...[
                    Text(
                      _breathingText, // Rodyti atitinkamą tekstą pagal kvėpavimo etapą
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _timerText, // Rodyti atbulinį laiką
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isBreathing ? null : _startBreathing,
                    child: Text(_isBreathing ? 'Kvėpuoti' : 'Pradėti'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
