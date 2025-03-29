import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sveikuoliai/models/habit_model.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';
import 'package:sveikuoliai/screens/habit.dart';
import 'package:sveikuoliai/services/habit_progress_services.dart'; // <-- Pridėtas servisų importas
import 'package:sveikuoliai/services/habit_services.dart';
import 'package:sveikuoliai/services/plant_image_services.dart';
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:sveikuoliai/widgets/custom_snack_bar.dart';

class HabitProgressScreen extends StatefulWidget {
  final HabitInformation habit;
  const HabitProgressScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitProgressScreenState createState() => _HabitProgressScreenState();
}

class _HabitProgressScreenState extends State<HabitProgressScreen> {
  final TextEditingController _progressController = TextEditingController();
  String? _currentProgressId; // Saugo esamo progreso ID, jei jis egzistuoja
  int pointss = 0;
  int streakk = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Užkrauna esamą progresą
  void _loadProgress() async {
    final habitProgressService = HabitProgressService();
    HabitProgress? progress =
        await habitProgressService.getTodayHabitProgress(widget.habit.id);
    HabitProgress? lastProgress =
        await habitProgressService.getLatestHabitProgress(widget.habit.id);

    if (progress != null) {
      setState(() {
        _progressController.text = progress.description;
        _currentProgressId = progress.id; // Išsaugome ID atnaujinimui
        pointss = lastProgress!.points;
        streakk = lastProgress.streak;
      });
    } else if (lastProgress != null) {
      setState(
        () {
          pointss = lastProgress!.points;
          if (lastProgress.date.day == DateTime.now().day - 1) {
            streakk = lastProgress.streak;
          }
        },
      );
    }
  }

  // Išsaugo arba atnaujina progresą
  void _saveProgress() async {
    final habitProgressService = HabitProgressService();
    final habitService = HabitService();

    HabitProgress habitProgress = HabitProgress(
      id: _currentProgressId ??
          '${widget.habit.habitTypeId}${widget.habit.userId[0].toUpperCase() + widget.habit.userId.substring(1)}${DateTime.now()}',
      habitId: widget.habit.id,
      description: _progressController.text,
      points: _currentProgressId != null ? pointss : ++pointss,
      streak: _currentProgressId != null ? streakk : ++streakk,
      plantUrl: PlantImageService.getPlantImage(widget.habit.plantId, pointss),
      date: DateTime.now(),
      isCompleted: true,
    );

    HabitModel habit = HabitModel(
        id: widget.habit.id,
        startDate: widget.habit.startDate,
        endDate: widget.habit.endDate,
        points: habitProgress.points,
        category: widget.habit.category,
        endPoints: widget.habit.endPoints,
        repetition: widget.habit.repetition,
        userId: widget.habit.userId,
        habitTypeId: widget.habit.habitTypeId,
        plantId: widget.habit.plantId);

    if (_currentProgressId != null) {
      await habitProgressService.updateHabitProgressEntry(habitProgress);
      if (mounted) {
        showCustomSnackBar(context, 'Progresas atnaujintas! ✅', true);
      }
    } else {
      await habitProgressService.createHabitProgressEntry(habitProgress);
      await habitService.updateHabitEntry(habit);
      if (mounted) {
        setState(() {
          _currentProgressId = habitProgress.id;
        });
        showCustomSnackBar(context, 'Progresas išsaugotas! 🎉', true);
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
                color: Color(0xFFCF9CFF),
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Atnaujink savo progresą',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    widget.habit.habitType.title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rodyti šios dienos datą
                  Text(
                    'Data: $formattedDate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Įvedimo lauko pavadinimas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Šios dienos progresas:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Įvedimo laukas su esamu progresu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _progressController,
                      maxLines: null, // Automatinis dydžio keitimas
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: 'Įveskite informaciją',
                        labelStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Išsaugojimo mygtukas
                  ElevatedButton(
                    onPressed: () {
                      _saveProgress();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HabitScreen(
                                  habit: widget.habit,
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      iconColor: const Color(0xFFB388EB),
                    ),
                    child: const Text(
                      'Išsaugoti',
                      style: TextStyle(fontSize: 20),
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
