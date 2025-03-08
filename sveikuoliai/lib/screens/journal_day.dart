import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importuojame intl paketą
import 'package:sveikuoliai/widgets/bottom_navigation.dart';

class JournalDayPage extends StatefulWidget {
  final DateTime selectedDay;

  const JournalDayPage({super.key, required this.selectedDay});

  @override
  _JournalDayPageState createState() => _JournalDayPageState();
}

class _JournalDayPageState extends State<JournalDayPage> {
  late DateTime selectedDay;
  String? selectedMood;
  String journalText = '';

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDay = DateTime.now();

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
                color: Color(0xFFFCE5FC),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Color(0xFFFCE5FC), width: 10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            selectedDay =
                                selectedDay.subtract(Duration(days: 1));
                          });
                        },
                      ),
                      Text(
                        _formatDay(selectedDay.day),
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      if (!isToday(selectedDay, currentDay))
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: () {
                            setState(() {
                              selectedDay = selectedDay.add(Duration(days: 1));
                            });
                          },
                        )
                      else
                        SizedBox(width: 48),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _capitalizeMonth(
                            DateFormat.MMMM('lt_LT').format(selectedDay)),
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 480, // Nustatykite aukštį pagal poreikį
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            Text('Šiandien jaučiuosi:',
                                style: TextStyle(fontSize: 15)),
                            SizedBox(height: 10),
                            _buildMoodCircle('Laiminga'),
                            _buildMoodCircle('Liūdna'),
                            _buildMoodCircle('Nusivylusi'),
                            _buildMoodCircle('Euforija'),
                            _buildMoodCircle('Rami'),
                          ],
                        ),
                      ),
                      Container(height: 480, width: 1, color: Colors.grey),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 100,
                              color: const Color(0xFFD9D9D9),
                              child: Center(
                                child: Text(
                                  'Vizualas',
                                  style: TextStyle(
                                      fontSize: 37, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () {
                                  String tempText =
                                      journalText; // Laikinas kintamasis įvestam tekstui
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                          left: 20,
                                          right: 20,
                                          top: 20,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              maxLines: null,
                                              autofocus: true,
                                              onChanged: (value) {
                                                tempText =
                                                    value; // Atnaujiname laikinojo kintamojo reikšmę
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Rašykite čia...',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  journalText =
                                                      tempText; // Išsaugome tekstą
                                                });
                                                Navigator.pop(
                                                    context); // Uždaro modalą
                                              },
                                              child: Text('Išsaugoti'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 115,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.transparent, width: 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      journalText.isEmpty
                                          ? 'Įrašyk savo mintis\n································\n································\n································'
                                          : journalText,
                                      style: TextStyle(
                                          color: Color(0xFFB388EB),
                                          fontSize: 18),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 200,
                              height: 150,
                              color: const Color(0xFFD9D9D9),
                              child: Center(
                                child: Text(
                                  'Įkelti nuotrauką',
                                  style: TextStyle(
                                      fontSize: 37, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 150, // Užpildo visą galimą plotį
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {});
                                  Navigator.pop(context); // Uždaro modalą
                                },
                                child: Text(
                                  'Išsaugoti',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  bool isToday(DateTime selectedDay, DateTime currentDay) {
    return selectedDay.year == currentDay.year &&
        selectedDay.month == currentDay.month &&
        selectedDay.day == currentDay.day;
  }

  String _capitalizeMonth(String month) {
    return month[0].toUpperCase() + month.substring(1);
  }

  String _formatDay(int day) {
    return day.toString().padLeft(2, '0');
  }

  Widget _buildMoodCircle(String mood) {
    bool isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = mood;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: isSelected ? Color(0xFFB388EB) : Color(0xFFFCE5FC),
            child: Icon(Icons.circle, color: Color(0xFFD9D9D9), size: 70),
          ),
          Text(mood,
              style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
