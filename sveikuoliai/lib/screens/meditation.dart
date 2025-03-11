import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _circleFadeAnimation;
  bool _isBreathing = false;
  late Timer _breathTimer = Timer(Duration(seconds: 0), () {});

  int _breathStage = 0; // 0 = Inhale, 1 = Hold, 2 = Exhale
  int _elapsedTime = 0; // Sekundės pagal etapus
  int _counts = 0; // Kiek kartų atlikta ciklą

  // Nustatome trukmes (sekundėmis) kiekvienam etapui
  final int inhaleDuration = 3; // Įkvėpimas
  final int holdDuration = 3; // Sulaikymas
  final int exhaleDuration = 4; // Iškvepimas
  int totalCycleRepetiton = 2; // Bendras ciklo laikas (kartojasi)

  String _breathingText = ""; // Pridėjome kintamąjį tekstui saugoti
  String _timerText = ""; // Atbulinio laikymo tekstas

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: inhaleDuration),
    );

    _sizeAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(_controller);
    _circleFadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_breathTimer.isActive) {
      _breathTimer.cancel(); // Atšaukti timer, jei jis aktyvus
    }
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _breathStage = 0; // Nustatome, kad ciklas prasideda nuo įkvėpimo
      _elapsedTime = 0; // Atnaujiname laiką
      _counts = 0; // Nustatome ciklų skaičių į 0
      _breathingText = "Įkvėpiama"; // Pradinis tekstas
      _timerText =
          inhaleDuration.toString(); // Užrašykite laiką nuo pirmos sekundės
    });

    // Timer'is valdo kvėpavimo etapus
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++; // Didiname laiką
      });

      if (_breathStage == 0) {
        // Įkvėpimas (3 sekundės)
        if (_elapsedTime <= inhaleDuration) {
          _controller.forward();
          setState(() {
            _timerText =
                (inhaleDuration - _elapsedTime).toString(); // Atbulinis laikas
          });
        } else {
          setState(() {
            _breathStage = 1; // Pereiname į sulaikymą
            _elapsedTime = 0; // Resetuoja laiką sulaikymo etapui
            _breathingText = "Sulaikyk"; // Atnaujintas tekstas
            _timerText =
                holdDuration.toString(); // Atbulinis laikas sulaikymo etapui
          });
          _controller.stop();
        }
      } else if (_breathStage == 1) {
        // Sulaikymas (3 sekundės)
        if (_elapsedTime <= holdDuration) {
          setState(() {
            _timerText =
                (holdDuration - _elapsedTime).toString(); // Atbulinis laikas
          });
        } else {
          setState(() {
            _breathStage = 2; // Pereiname į iškvėpimą
            _elapsedTime = 0; // Resetuoja laiką iškvėpimo etapui
            _breathingText = "Iškvepiama"; // Atnaujintas tekstas
            _timerText =
                exhaleDuration.toString(); // Atbulinis laikas iškvėpimo etapui
          });
          _controller.reverse();
        }
      } else if (_breathStage == 2) {
        // Iškvepimas (4 sekundės)
        if (_elapsedTime <= exhaleDuration) {
          _controller.reverse();
          setState(() {
            _timerText =
                (exhaleDuration - _elapsedTime).toString(); // Atbulinis laikas
          });
        } else {
          setState(() {
            _breathStage = 0; // Pradeda naują ciklą
            _elapsedTime = 0; // Resetuoja laiką
            _counts++; // Padidiname atliktų ciklų skaičių
            _breathingText = "Įkvėpiama";
            _timerText =
                inhaleDuration.toString(); // Atbulinis laikas įkvėpimo etapui
          });
          _controller.reset();
        }
      }

      // Baigiam meditaciją, kai atlikta tiek ciklų, kiek numatyta
      if (_counts >= totalCycleRepetiton) {
        _breathTimer.cancel();
        setState(() {
          _isBreathing = false;
          _breathingText =
              "Meditacija baigta"; // Pridėjome užrašą po meditacijos
        });

        // Resetavimas po meditacijos
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _breathingText = ""; // Išvalome kvėpavimo tekstą
            _counts = 0; // Nustatome ciklų skaičių į 0
            _breathStage = 0; // Nustatome kvėpavimo etapą į pradžios būseną
            _elapsedTime = 0; // Išvalome laiką
          });
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = 250;
    double circleRadius = (iconSize * 1.1) / 2;

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
                        icon: Icon(
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
                  SizedBox(height: 20),
                  Text(
                    'Meditacija',
                    style: TextStyle(fontSize: 35),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animuojamas apskritimas, kuris pradeda keisti permatomumą
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: BreathingCirclePainter(
                                  radius: circleRadius,
                                  opacity: _circleFadeAnimation.value,
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Icon(
                                Icons.self_improvement,
                                size: iconSize * _sizeAnimation.value,
                                color: Color(0xFFB388EB),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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

class BreathingCirclePainter extends CustomPainter {
  final double radius;
  final double opacity;

  BreathingCirclePainter({required this.radius, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFFB388EB).withOpacity(opacity)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
