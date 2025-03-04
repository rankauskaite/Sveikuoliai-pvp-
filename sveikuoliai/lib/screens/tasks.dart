import 'package:flutter/material.dart';
import 'package:sveikuoliai/main.dart';
import 'package:sveikuoliai/screens/journal.dart';
import 'package:sveikuoliai/screens/profile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

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
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Pirmas mygtukas
                            print('Pirmas mygtukas paspaustas');
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(30), // Suapvalinti kampai
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            iconColor:
                                Color(0xFF8093F1), // Spalva pirmam mygtukui
                          ),
                          child: const Text('Mano įpročiai'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Antras mygtukas
                            print('Antras mygtukas paspaustas');
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight:
                                    Radius.circular(30), // Suapvalinti kampai
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            iconColor:
                                Color(0xFFB388EB), // Spalva antram mygtukui
                          ),
                          child: const Text('Mano tikslai'),
                        ),
                      ),
                    ],
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
