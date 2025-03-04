import 'package:flutter/material.dart';
import 'package:sveikuoliai/main.dart';
import 'package:sveikuoliai/screens/profile.dart';
import 'package:sveikuoliai/screens/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

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
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Išlaikyti kairę, galite keisti į 'center' ar 'end'
                    children: [
                      IconButton(
                        icon: const Icon(Icons.account_circle, size: 60),
                        color: const Color(0xFFD9D9D9),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                          );
                        },
                      ),
                    ],
                  ),
                  //const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centruoti horizontaliai
                    children: [
                      Container(
                        width: 250, // Nustatykite plotį
                        height: 80, // Nustatykite aukštį
                        color: const Color(0xFFD9D9D9), // Spalva
                        child: Text(
                          'Vizualas su užrašu dienoraštis(?) Jei ką - papildomas reklamos plotas',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  //Čia pridedame kalendorių
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 01, 01),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: DateTime.now(),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      print('Selected day: $selectedDay');
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    SizedBox(height: 10), // Vietos pridėjimas virš ikonos
                    Container(
                      width: 50, // Apskritimo plotis
                      height: 50, // Apskritimo aukštis
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9), // Apskritimo spalva
                        shape: BoxShape.circle, // Apskritimo forma
                      ),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.library_books_outlined,
                              size: 35), // Ikonos dydis
                          color: const Color(0xFF8093F1),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const JournalPage()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: 10), // Vietos pridėjimas virš ikonos
                    Container(
                      width: 50, // Apskritimo plotis
                      height: 50, // Apskritimo aukštis
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9), // Apskritimo spalva
                        shape: BoxShape.circle, // Apskritimo forma
                      ),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.home_outlined,
                              size: 35), // Ikonos dydis
                          color: const Color(0xFF8093F1),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: 10), // Vietos pridėjimas virš ikonos
                    Container(
                      width: 50, // Apskritimo plotis
                      height: 50, // Apskritimo aukštis
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9), // Apskritimo spalva
                        shape: BoxShape.circle, // Apskritimo forma
                      ),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              size: 35), // Ikonos dydis
                          color: const Color(0xFF8093F1),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TasksPage()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
