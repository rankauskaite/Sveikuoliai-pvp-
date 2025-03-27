import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importuojame intl paketą
import 'package:sveikuoliai/widgets/bottom_navigation.dart';
import 'package:table_calendar/table_calendar.dart';

class JournalDayScreen extends StatefulWidget {
  final DateTime selectedDay;

  const JournalDayScreen({super.key, required this.selectedDay});

  @override
  _JournalDayScreenState createState() => _JournalDayScreenState();
}

class _JournalDayScreenState extends State<JournalDayScreen> {
  late DateTime selectedDay;
  String? selectedMood;
  String journalText = '';
  DateTime? menstruationStart;
  late DateTime selectedTempDay = selectedDay; // Laikinas pasirinkimas

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedDay;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Apskaičiuojame eilučių skaičių pagal pasirinktą mėnesį
        int rowCount = _getRowCountForMonth(selectedDay);
        return Container(
          height: 170 +
              rowCount *
                  40.0, // Dinaminis aukštis priklausomai nuo eilučių skaičiaus
          child: Column(
            children: [
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime.now(),
                  locale: 'lt_LT',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: 40,
                  focusedDay: selectedTempDay ??
                      selectedDay!, // Atvaizduojama fokusuota diena
                  selectedDayPredicate: (day) {
                    // Patikriname, ar diena yra menstruacijų pradžia
                    return selectedTempDay != null &&
                        day.year == selectedTempDay!.year &&
                        day.month == selectedTempDay!.month &&
                        day.day == selectedTempDay!.day;
                  },
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState(() {
                      selectedTempDay =
                          selectedDay; // Užtikriname, kad menstruacijų pradžia būtų nustatyta iškart
                    });

                    // Uždaryti kalendorių
                    Navigator.pop(context);

                    // Palaukite, kad uždarymas įvyktų, ir tada atidarykite vėl su nauju fokusavimu
                    Future.delayed(Duration(milliseconds: 1), () {
                      _selectDate(context); // Atidaryti kalendorių iš naujo
                    });
                  },

                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.arrow_back),
                    rightChevronIcon: Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context), // Uždaryti modalą be pakeitimų
                    child: Text('Atšaukti'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        menstruationStart =
                            selectedTempDay; // Išsaugome pasirinktą menstruacijų dieną
                      });
                      Navigator.pop(context); // Uždaryti modalą
                    },
                    child: Text('Gerai'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  int _getRowCountForMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    // Apskaičiuojame, kiek dienų yra šiame mėnesyje
    int totalDaysInMonth = lastDayOfMonth.day;

    // Grąžiname eilučių skaičių
    return (totalDaysInMonth / 7).ceil();
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
                            _buildMoodCircle('Laiminga',
                                'assets/images/nuotaikos/laiminga.png'),
                            _buildMoodCircle(
                                'Liūdna', 'assets/images/nuotaikos/liudna.png'),
                            _buildMoodCircle(
                                'Pikta', 'assets/images/nuotaikos/pikta.png'),
                            _buildMoodCircle('Pavargusi',
                                'assets/images/nuotaikos/pavargus.png'),
                            _buildMoodCircle('Motyvuota',
                                'assets/images/nuotaikos/motyvuota.png'),
                            _buildMoodCircle('Ryžtinga',
                                'assets/images/nuotaikos/ryztingaStipri.png'),
                            _buildMoodCircle('Suglumusi',
                                'assets/images/nuotaikos/suglumusi.png'),
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
                            SizedBox(height: 5),
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
                              height: 5,
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
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Text(
                                'Pažymėti mėnesines',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            if (menstruationStart != null &&
                                !selectedDay.isBefore(menstruationStart!) &&
                                selectedDay
                                        .difference(menstruationStart!)
                                        .inDays <
                                    7)
                              Text(
                                'Šiandien yra ${selectedDay.difference(menstruationStart!).inDays + 1} mėnesinių diena',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
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

  Widget _buildMoodCircle(String mood, String imageUrl) {
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
            radius: 37,
            backgroundColor: isSelected ? Colors.deepPurple : Color(0xFFFCE5FC),
            child: Image.asset(imageUrl, width: 70, height: 70),
          ),
          Text(mood,
              style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
