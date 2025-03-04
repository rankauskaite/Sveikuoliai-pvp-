import 'package:flutter/material.dart';
import 'package:sveikuoliai/main.dart';
import 'package:sveikuoliai/screens/journal.dart';
import 'package:sveikuoliai/screens/settings.dart';
import 'package:sveikuoliai/screens/tasks.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                        icon: Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Icon(
                        Icons.edit_outlined,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()),
                          );
                        },
                        icon: Icon(
                          Icons.settings_outlined,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.account_circle,
                    size: 200,
                    color: Color(0xFFD9D9D9),
                  ),
                  const Text(
                    'VARDAS',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'USERNAME',
                    style: TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mano duomenys',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'el. paštas',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'asesumergaite@gmail.com',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFB388EB),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFB388EB),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'kita...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '2009-05-16',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFB388EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Versija: ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'nemokama',
                        style:
                            TextStyle(fontSize: 15, color: Color(0xFF8093F1)),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      iconColor: const Color(0xFF8093F1), // Violetinė spalva
                    ),
                    child: const Text(
                      'Draugai',
                      style: TextStyle(fontSize: 20),
                    ),
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
